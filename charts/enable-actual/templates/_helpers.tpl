{{- define "enable-actual.name" -}}
{{- default .Chart.Name .Values.nameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "enable-actual.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "enable-actual.name" .) | lower | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "enable-actual.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "enable-actual.labels" -}}
helm.sh/chart: {{ include "enable-actual.chart" . }}
app.kubernetes.io/name: {{ include "enable-actual.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "enable-actual.pvcName" -}}
{{- printf "%s-data" (include "enable-actual.fullname" .) -}}
{{- end -}}

