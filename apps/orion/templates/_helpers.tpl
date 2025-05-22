{{- define "orion.fullname" -}}
{{ printf "orion-%s" .Values.service.name }}
{{- end }}

{{- define "orion.labels" -}}
app: {{ include "orion.fullname" . }}
{{- end }}

