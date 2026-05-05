{{- define "actual-budget.name" -}}
{{- default .Chart.Name .Values.nameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "actual-budget.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "actual-budget.name" .) | lower | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "actual-budget.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "actual-budget.labels" -}}
helm.sh/chart: {{ include "actual-budget.chart" . }}
app.kubernetes.io/name: {{ include "actual-budget.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "actual-budget.actualServiceName" -}}
{{- printf "%s-actual" (include "actual-budget.fullname" .) -}}
{{- end -}}

{{- define "actual-budget.actualPvcName" -}}
{{- printf "%s-data" (include "actual-budget.actualServiceName" .) -}}
{{- end -}}

