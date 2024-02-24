variable "conformance_pack" {
  type        = string
  description = "The URL to a Conformance Pack"
}

variable "access_token" {
  type        = string
  description = "Optional: access token required to access private GitHub repos, where custom conformance packs could be stored"
  default     = ""
}

variable "parameter_overrides" {
  type        = map(any)
  description = "A map of parameters names to values to override from the template"
  default     = {}
}
