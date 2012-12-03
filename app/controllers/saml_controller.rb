class SamlController < ApplicationController
    def init
      request = Onelogin::Saml::Authrequest.new
      redirect_to(request.create(saml_settings))
    end

    def consume
      response = Onelogin::Saml::Response.new(params[:SAMLResponse])
      response.settings = saml_settings

      if response.is_valid?
        render :text => "Authenticated as #{response.name_id}"
      else
        render :text => "Failure"
        
      end
    end

    private

    def saml_settings
      settings = Onelogin::Saml::Settings.new

      settings.assertion_consumer_service_url = saml_consume_url(host: request.host)
      settings.issuer                         = "http://#{request.port == 80 ? request.host : request.host_with_port}"
      settings.idp_sso_target_url             = "https://primedia.okta.com/app/template_saml/k18eco74OXEHHWDWRDMZ/sso/saml"
      settings.idp_cert_fingerprint           = "C4:AD:2D:F4:5E:47:B6:85:BC:09:DD:48:DF:4B:42:8D:E3:A0:10:09"
      settings.name_identifier_format         = "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"
      # Optional for most SAML IdPs
      settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

      settings
    end
  end