class SamlController < ApplicationController
    def init
      request = Onelogin::Saml::Authrequest.new
      raise saml_settings.issuer.inspect
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
      settings.idp_sso_target_url             = "https://jaredbranum.okta.com/home/template_saml_2_0/0oa1ny13dcLZNMYMERHB/3079"#{}"https://app.onelogin.com/saml/signon/#{OneLoginAppId}"
      settings.idp_cert_fingerprint           = "CD:C7:C0:8A:DD:0E:0E:94:B1:33:0A:CA:EC:08:29:CC:44:85:A8:23"
      settings.name_identifier_format         = "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"
      # Optional for most SAML IdPs
      settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

      settings
    end
  end