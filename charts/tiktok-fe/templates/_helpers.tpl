{{/*
============================================================================
TikTok Frontend - Helm Template Helpers
============================================================================
This file contains helper templates used across all Kubernetes manifests.
These helpers provide consistent naming, labels, and selectors.
============================================================================
*/}}

{{/*
Expand the name of the chart.
Used as a base for resource naming.
Falls back to chart name if nameOverride is not set.
*/}}
{{- define "tiktok-fe.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this.
If fullnameOverride is provided, use that.
If release name contains chart name, use release name.
Otherwise, combine release name and chart name.
*/}}
{{- define "tiktok-fe.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
This is useful for tracking which chart version deployed the resources.
*/}}
{{- define "tiktok-fe.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources.
These labels follow Kubernetes recommended label conventions.
https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
*/}}
{{- define "tiktok-fe.labels" -}}
helm.sh/chart: {{ include "tiktok-fe.chart" . }}
{{ include "tiktok-fe.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: tiktok-clone
{{- end }}

{{/*
Selector labels used for pod selection.
These labels are used by Services and Deployments to select pods.
IMPORTANT: These must NOT change after initial deployment.
*/}}
{{- define "tiktok-fe.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tiktok-fe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
If serviceAccount.create is true, use the generated name.
If serviceAccount.name is provided, use that.
Otherwise, use the default service account.
*/}}
{{- define "tiktok-fe.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tiktok-fe.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the image reference string.
Combines repository and tag with proper formatting.
*/}}
{{- define "tiktok-fe.image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- end }}

{{/*
Generate environment variables from values.
Handles plain env vars, secrets, and configmaps.
*/}}
{{- define "tiktok-fe.envVars" -}}
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- range .Values.envSecrets }}
- name: {{ .name }}
  valueFrom:
    secretKeyRef:
      name: {{ .secretName }}
      key: {{ .secretKey }}
{{- end }}
{{- range .Values.envConfigMaps }}
- name: {{ .name }}
  valueFrom:
    configMapKeyRef:
      name: {{ .configMapName }}
      key: {{ .configMapKey }}
{{- end }}
{{- end }}

{{/*
Create resource name with suffix.
Useful for creating related resources like ConfigMaps, Secrets.
*/}}
{{- define "tiktok-fe.resourceName" -}}
{{- $fullname := include "tiktok-fe.fullname" . -}}
{{- $suffix := index . 1 -}}
{{- printf "%s-%s" $fullname $suffix | trunc 63 | trimSuffix "-" -}}
{{- end }}
