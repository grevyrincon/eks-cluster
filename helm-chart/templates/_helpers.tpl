{{- define "python-api.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 -}}
{{- end -}}