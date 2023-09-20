resource "okta_app_saml" "CyberArk" {
  assertion_signed               = "false"
  audience                       = "https://${var.url}/PasswordVault/api/auth/saml/logon"
  authn_context_class_ref        = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
  auto_submit_toolbar            = "false"
  default_relay_state            = "https://${var.url}/PasswordVault/api/auth/saml/logon"
  destination                    = "https://${var.url}/PasswordVault/api/auth/saml/logon"
  digest_algorithm               = "SHA256"
  hide_ios                       = "true"
  hide_web                       = "true"
  honor_force_authn              = "true"
  idp_issuer                     = "http://www.okta.com/$${org.externalKey}"
  implicit_assignment            = "false"
  label                          = var.env == "prd" ? "CyberArk" : "CyberArk ${var.env}"
  recipient                      = "https://${var.url}/PasswordVault/api/auth/saml/logon"
  response_signed                = "true"
  saml_signed_request_enabled    = "false"
  saml_version                   = "2.0"
  signature_algorithm            = "RSA_SHA256"
  sso_url                        = "https://${var.url}/PasswordVault/api/auth/saml/logon"
  status                         = "ACTIVE"
  subject_name_id_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"
  subject_name_id_template       = "$${user.userName}"
  user_name_template             = "$${source.samAccountName}"
  user_name_template_type        = "BUILT_IN"
}

# Create CyberArk Group
resource "okta_group" "CyberArk_Users" {
  description = "CyberArk Users"
  name        = "CyberArk_Users"
}

# Group Assignment - Assign CyberArk_Users group to CyberArk App
resource "okta_app_group_assignment" "CyberArk" {
  app_id   = "okta_app_saml.CyberArk.id"
  group_id = "okta_group.CyberArk_Users.id"
}

# Group Rule
resource "okta_group_rule" "CyberArk_Rule" {
  expression_value  = "isMemberOfGroupNameContains(\"epv.nic.acct_\")"
  group_assignments = [okta_group.CyberArk_Users.id]
  name              = "Add users to CyberArk group"
  status            = "ACTIVE"
}