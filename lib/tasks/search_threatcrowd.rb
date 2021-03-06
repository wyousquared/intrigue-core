module Intrigue
module Task
class SearchThreatcrowd < BaseTask
  include Intrigue::Task::Web

  def self.metadata
    {
      :name => "search_threatcrowd",
      :pretty_name => "Search ThreatCrowd",
      :authors => ["jcran"],
      :description => "This task hits the ThreatCrowd API and finds related content. Discovered IPs / subdomains / emails are created.",
      :references => [],
      :type => "discovery",
      :passive => true,
      :allowed_types => ["DnsRecord"],
      :example_entities => [{"type" => "DnsRecord", "details" => {"name" => "intrigue.io"}}],
      :allowed_options => [
        {:name => "gather_resolutions", :type => "Boolean", :regex => "boolean", :default => true },
        {:name => "gather_subdomains", :type => "Boolean", :regex => "boolean", :default => true },
        {:name => "gather_email_addresses", :type => "Boolean", :regex => "boolean", :default => true }
      ],
      :created_types => ["DnsRecord", "EmailAddress", "IpAddress"]
    }
  end

  ## Default method, subclasses must override this
  def run
    super

    opt_gather_resolutions = _get_option "gather_resolutions"
    opt_gather_subdomains = _get_option "gather_subdomains"
    opt_gather_email_addresses = _get_option "gather_email_addresses"

    # Check Sublist3r API & create domains from returned JSON
    search_domain = _get_entity_name
    search_uri = "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=#{search_domain}"
    begin
      tc_json = JSON.parse(http_get_body(search_uri))

      if tc_json["response_code"] == "1"

        # handle IP resolution
        if opt_gather_resolutions
          tc_json["resolutions"].each do |ip|
            _create_entity "IpAddress", {
              "name" => ip["ip_address"],
              "resolver" => "threatcrowd",
              "last_resolved" => ip["last_resolved"]
            }
          end
        end

        # Handle Subdomains
        if opt_gather_subdomains
          tc_json["subdomains"].each do |d|
            # seems like this needs some cleanup?
            d.gsub!(":","")
            d.gsub!(" ","")
            _create_entity "DnsRecord", { "name" => d }
          end
        end

        # Handle Emails
        if opt_gather_email_addresses
          tc_json["emails"].each do |e|
            _create_entity "EmailAddress", { "name" => e }
          end
        end

      else
        _log_error "Got error code: #{tc_json["response_code"]}"
      end

    rescue JSON::ParserError => e
      _log_error "Unable to get parsable response from #{search_uri}: #{e}"
    rescue StandardError => e
      _log_error "Error grabbing sublister domains: #{e}"
    end



  end # end run()

end # end Class
end
end
