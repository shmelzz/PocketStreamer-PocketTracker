package metrics

import "github.com/prometheus/client_golang/prometheus"

var (
	// JSONDataStatus tracks the number of successful and failed JSON data transmissions
	ComposerDataStatus = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "send_to_composer_status_total",
			Help: "Total number of JSON data transmissions, labeled by status",
		},
		[]string{"status"},
	)
)

func init() {
	prometheus.MustRegister(ComposerDataStatus)
}
