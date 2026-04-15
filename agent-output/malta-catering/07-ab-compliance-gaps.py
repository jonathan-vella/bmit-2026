"""Generate the compliance gaps chart for Malta Catering."""

import matplotlib.pyplot as plt


def generate_compliance_gaps_chart(gaps: dict[str, int], output_path: str) -> None:
    colors = {
        "Critical": "#C00000",
        "High": "#D83B01",
        "Medium": "#FFB900",
        "Low": "#107C10",
    }

    labels = list(gaps.keys())
    values = list(gaps.values())

    fig, ax = plt.subplots(figsize=(8, 3.5))
    fig.patch.set_facecolor("#F8F9FA")
    ax.set_facecolor("#F8F9FA")

    bars = ax.barh(labels, values, color=[colors[label] for label in labels], height=0.5, edgecolor="white", linewidth=1.2)

    for bar, value in zip(bars, values):
        ax.text(bar.get_width() + 0.10, bar.get_y() + bar.get_height() / 2, str(value), va="center", fontsize=11, fontweight="bold", color="#333")

    ax.set_xlim(0, max(values) * 1.5)
    ax.set_xlabel("Number of Gaps", fontsize=10, color="#555")
    ax.set_title("Compliance Gaps by Severity", fontsize=13, fontweight="bold", color="#1A1A2E", pad=14)
    ax.tick_params(axis="y", labelsize=10, colors="#333")
    ax.spines[["top", "right"]].set_visible(False)
    ax.spines[["left", "bottom"]].set_color("#DDD")
    ax.grid(axis="x", color="#E0E0E0", linewidth=0.8, alpha=0.7)

    plt.tight_layout(pad=1.4)
    plt.savefig(output_path, dpi=150, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close()


if __name__ == "__main__":
    generate_compliance_gaps_chart(
        {
            "Critical": 0,
            "High": 1,
            "Medium": 2,
            "Low": 2,
        },
        "agent-output/malta-catering/07-ab-compliance-gaps.png",
    )
"""Generate the compliance gaps chart for Malta Catering."""

import matplotlib.pyplot as plt


def generate_compliance_gaps_chart(gaps: dict[str, int], output_path: str) -> None:
    colors = {
        "Critical": "#C00000",
        "High": "#D83B01",
        "Medium": "#FFB900",
        "Low": "#107C10",
    }

    labels = list(gaps.keys())
    values = list(gaps.values())

    fig, ax = plt.subplots(figsize=(8, 3.5))
    fig.patch.set_facecolor("#F8F9FA")
    ax.set_facecolor("#F8F9FA")

    bars = ax.barh(labels, values, color=[colors[label] for label in labels], height=0.5, edgecolor="white", linewidth=1.2)

    for bar, value in zip(bars, values):
        ax.text(bar.get_width() + 0.10, bar.get_y() + bar.get_height() / 2, str(value), va="center", fontsize=11, fontweight="bold", color="#333")

    ax.set_xlim(0, max(values) * 1.5)
    ax.set_xlabel("Number of Gaps", fontsize=10, color="#555")
    ax.set_title("Compliance Gaps by Severity", fontsize=13, fontweight="bold", color="#1A1A2E", pad=14)
    ax.tick_params(axis="y", labelsize=10, colors="#333")
    ax.spines[["top", "right"]].set_visible(False)
    ax.spines[["left", "bottom"]].set_color("#DDD")
    ax.grid(axis="x", color="#E0E0E0", linewidth=0.8, alpha=0.7)

    plt.tight_layout(pad=1.4)
    plt.savefig(output_path, dpi=150, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close()


if __name__ == "__main__":
    generate_compliance_gaps_chart(
        {
            "Critical": 0,
            "High": 1,
            "Medium": 2,
            "Low": 2,
        },
        "agent-output/malta-catering/07-ab-compliance-gaps.png",
    )
