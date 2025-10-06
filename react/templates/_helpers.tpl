{{- define "reactapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "reactapp.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "reactapp.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}