"""Malta Catering — Bicep Module Dependency Graph.

Shows deployment ordering across 5 phases with explicit module dependencies.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.azure.compute import AppServices
from diagrams.azure.database import BlobStorage
from diagrams.azure.devops import Repos
from diagrams.azure.monitor import Monitor, ApplicationInsights
from diagrams.azure.network import VirtualNetworks, DNSZones
from diagrams.azure.security import KeyVaults
from diagrams.azure.general import Helpsupport

graph_attr = {
    "bgcolor": "white",
    "pad": "0.8",
    "nodesep": "0.9",
    "ranksep": "1.0",
    "splines": "spline",
    "fontname": "Arial Bold",
    "fontsize": "16",
    "dpi": "150",
    "label": "Malta Catering — Module Dependency Graph",
    "labelloc": "t",
}
node_attr = {"fontname": "Arial Bold", "fontsize": "11", "labelloc": "t"}

with Diagram(
    "",
    filename="agent-output/malta-catering/04-dependency-diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
):
    with Cluster("Phase 1: Foundation & Monitoring", graph_attr={"style": "dashed", "color": "#0078D4", "fontcolor": "#0078D4"}):
        log = Monitor("Log Analytics\nWorkspace")
        appi = ApplicationInsights("Application\nInsights")

    with Cluster("Phase 2: Networking", graph_attr={"style": "dashed", "color": "#5C2D91", "fontcolor": "#5C2D91"}):
        vnet = VirtualNetworks("Virtual Network\n(2 subnets)")
        dns = DNSZones("Private DNS\nZones (×3)")

    with Cluster("Phase 3: Security, Data & Images", graph_attr={"style": "dashed", "color": "#107C10", "fontcolor": "#107C10"}):
        kv = KeyVaults("Key Vault\n+ PE")
        st = BlobStorage("Storage Account\n(Table Storage) + PE")
        acr = Repos("Container\nRegistry + PE")

    with Cluster("Phase 4: Compute", graph_attr={"style": "dashed", "color": "#FF8C00", "fontcolor": "#FF8C00"}):
        asp = AppServices("App Service\nPlan (S1)")
        webapp = AppServices("Web App\n+ VNet Integration")

    with Cluster("Phase 5: Cost Monitoring", graph_attr={"style": "dashed", "color": "#C00000", "fontcolor": "#C00000"}):
        budget = Helpsupport("Consumption\nBudget")

    # Phase 1 internal
    log >> Edge(label="workspace", color="#0078D4") >> appi

    # Phase 1 → Phase 2 (diagnostics)
    log >> Edge(label="diagnostics", style="dashed", color="#666666") >> vnet

    # Phase 2 internal
    vnet >> Edge(label="VNet link", color="#5C2D91") >> dns

    # Phase 2 → Phase 3 (PE subnet + DNS)
    dns >> Edge(label="PE DNS", color="#5C2D91") >> kv
    dns >> Edge(label="PE DNS", color="#5C2D91") >> st
    dns >> Edge(label="PE DNS", color="#5C2D91") >> acr

    # Phase 1 → Phase 3 (diagnostics)
    log >> Edge(label="diagnostics", style="dashed", color="#666666") >> kv
    log >> Edge(label="diagnostics", style="dashed", color="#666666") >> st
    log >> Edge(label="diagnostics", style="dashed", color="#666666") >> acr

    # Phase 2 → Phase 4 (VNet integration subnet)
    vnet >> Edge(label="subnet delegation", color="#5C2D91") >> asp

    # Phase 4 internal
    asp >> Edge(label="plan", color="#FF8C00") >> webapp

    # Phase 3 → Web App
    acr >> Edge(label="image pull", color="#107C10") >> webapp
    kv >> Edge(label="secrets", color="#107C10") >> webapp
    st >> Edge(label="Table Storage", color="#107C10") >> webapp
    appi >> Edge(label="telemetry", color="#0078D4") >> webapp
