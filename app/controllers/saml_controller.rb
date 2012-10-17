class SamlController < ApplicationController
    def init
      request = Onelogin::Saml::Authrequest.new
      redirect_to(request.create(saml_settings))
    end

    def consume
      response = Onelogin::Saml::Response.new(params[:SAMLResponse])
      response.settings = saml_settings

      if response.is_valid?
        render :text => "Authenticated"
      else
        render :text => "Failure"
        
      end
    end

    private

    def saml_settings
      settings = Onelogin::Saml::Settings.new

      settings.assertion_consumer_service_url = "http://127.0.0.1:3020/saml/consume"
      settings.issuer                         = "http://127.0.0.1:3020"
      settings.idp_sso_target_url             = "http://127.0.0.1:3000/saml/auth"#{}"https://app.onelogin.com/saml/signon/#{OneLoginAppId}"
      settings.idp_cert_fingerprint           =  ""
      settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
      # Optional for most SAML IdPs
      settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

      settings
    end
  end