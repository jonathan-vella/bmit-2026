"""Malta Catering — Bicep Module Dependency Graph.

Shows deployment ordering across 4 phases with explicit module dependencies.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.azure.compute import ContainerApps
from diagrams.azure.database import BlobStorage
from diagrams.azure.devops import Repos
from diagrams.azure.integration import APIManagement
from diagrams.azure.monitor import Monitor, ApplicationInsights
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

    with Cluster("Phase 2: Security, Data & Images", graph_attr={"style": "dashed", "color": "#107C10", "fontcolor": "#107C10"}):
        kv = KeyVaults("Key Vault")
        st = BlobStorage("Storage Account\n(Table Storage)")
        acr = Repos("Container\nRegistry")

    with Cluster("Phase 3: Compute", graph_attr={"style": "dashed", "color": "#FF8C00", "fontcolor": "#FF8C00"}):
        cae = ContainerApps("Container Apps\nEnvironment")
        ca = ContainerApps("Container App")

    with Cluster("Phase 4: Cost Monitoring", graph_attr={"style": "dashed", "color": "#C00000", "fontcolor": "#C00000"}):
        budget = Helpsupport("Consumption\nBudget")

    # Phase 1 internal
    log >> Edge(label="workspace", color="#0078D4") >> appi

    # Phase 1 → Phase 2 (diagnostics)
    log >> Edge(label="diagnostics", style="dashed", color="#666666") >> kv
    log >> Edge(label="diagnostics", style="dashed", color="#666666") >> st
    log >> Edge(label="diagnostics", style="dashed", color="#666666") >> acr

    # Phase 1 → Phase 3
    log >> Edge(label="logs", style="dashed", color="#666666") >> cae

    # Phase 2/3 → Container App
    cae >> Edge(label="environment", color="#FF8C00") >> ca
    acr >> Edge(label="image pull", color="#107C10") >> ca
    kv >> Edge(label="secrets", color="#107C10") >> ca
    st >> Edge(label="Table Storage", color="#107C10") >> ca
    appi >> Edge(label="telemetry", color="#0078D4") >> ca
