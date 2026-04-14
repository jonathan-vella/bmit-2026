"""Malta Catering — Runtime Flow Diagram.

Shows request, authentication, secret, data, and telemetry paths at runtime.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.azure.compute import ContainerApps
from diagrams.azure.database import BlobStorage
from diagrams.azure.devops import Repos
from diagrams.azure.identity import ActiveDirectory
from diagrams.azure.monitor import Monitor, ApplicationInsights
from diagrams.azure.security import KeyVaults
from diagrams.onprem.client import Users

graph_attr = {
    "bgcolor": "white",
    "pad": "0.8",
    "nodesep": "0.9",
    "ranksep": "1.0",
    "splines": "spline",
    "fontname": "Arial Bold",
    "fontsize": "16",
    "dpi": "150",
    "label": "Malta Catering — Runtime Flow",
    "labelloc": "t",
}
node_attr = {"fontname": "Arial Bold", "fontsize": "11", "labelloc": "t"}

with Diagram(
    "",
    filename="agent-output/malta-catering/04-runtime-diagram",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
    node_attr=node_attr,
):
    customer = Users("Customer\n(Browser)")
    staff = Users("Staff\n(Browser)")

    with Cluster("Authentication", graph_attr={"style": "dashed", "color": "#5C2D91", "fontcolor": "#5C2D91"}):
        social_idp = ActiveDirectory("Social IdP\n(Google/MS)")
        entra = ActiveDirectory("Entra ID\n(Staff Auth)")

    with Cluster("Azure — swedencentral", graph_attr={"color": "#0078D4", "fontcolor": "#0078D4"}):
        with Cluster("Compute", graph_attr={"style": "dashed", "color": "#FF8C00", "fontcolor": "#FF8C00"}):
            ca = ContainerApps("Container App\nReact SPA + API")

        with Cluster("Security", graph_attr={"style": "dashed", "color": "#C00000", "fontcolor": "#C00000"}):
            kv = KeyVaults("Key Vault")

        with Cluster("Data", graph_attr={"style": "dashed", "color": "#107C10", "fontcolor": "#107C10"}):
            st = BlobStorage("Storage Account\n(Table Storage)")

        with Cluster("Images", graph_attr={"style": "dashed", "color": "#666666", "fontcolor": "#666666"}):
            acr = Repos("Container\nRegistry")

        with Cluster("Observability", graph_attr={"style": "dashed", "color": "#0078D4", "fontcolor": "#0078D4"}):
            log = Monitor("Log Analytics")
            appi = ApplicationInsights("App Insights")

    # Request paths
    customer >> Edge(label="HTTPS", color="#0078D4") >> ca
    staff >> Edge(label="HTTPS", color="#0078D4") >> ca

    # Auth paths
    customer >> Edge(label="OAuth 2.0", style="dashed", color="#5C2D91") >> social_idp
    staff >> Edge(label="Entra ID", style="dashed", color="#5C2D91") >> entra
    social_idp >> Edge(label="token", style="dashed", color="#5C2D91") >> ca
    entra >> Edge(label="JWT + roles", style="dashed", color="#5C2D91") >> ca

    # Secret path (Managed Identity)
    ca >> Edge(label="MI → secrets", color="#C00000") >> kv

    # Data path (Managed Identity)
    ca >> Edge(label="MI → tables", color="#107C10") >> st

    # Image pull
    acr >> Edge(label="image pull", style="dotted", color="#666666") >> ca

    # Telemetry paths
    ca >> Edge(label="logs", style="dashed", color="#0078D4") >> log
    ca >> Edge(label="telemetry", style="dashed", color="#0078D4") >> appi
