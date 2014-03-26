class CC::Service::Lighthouse < CC::Service
  class Config < CC::Service::Config
    attribute :subdomain, String,
      description: "Your Lighthouse subdomain"

    attribute :api_token, String,
      label: "API Token",
      description: "Your Lighthouse API Key (http://help.lighthouseapp.com/kb/api/how-do-i-get-an-api-token)"

    attribute :project_id, String,
      description: "Your Lighthouse project ID. You can find this from the URL to your Lighthouse project."

    attribute :tags, String,
      description: "Which tags to add to tickets, comma delimited"

    validates :subdomain, presence: true
    validates :api_token, presence: true
    validates :project_id, presence: true
  end

  self.title = "Lighthouse"
  self.issue_tracker = true
  self.custom_middleware = JSONMiddleware

  def receive_quality
    params = {
      ticket: {
        title: "Refactor #{constant_name} from #{rating} on Code Climate",
        body: details_url
      }
    }

    if config.tags.present?
      params[:ticket][:tags] = config.tags.strip
    end

    base_url = "https://#{config.subdomain}.lighthouseapp.com"
    url = "#{base_url}/projects/#{config.project_id}/tickets.json"

    http.headers["X-LighthouseToken"] = config.api_token
    res = http.post(url, params)

    {
      id:  res.body["ticket"]["number"],
      url: res.body["ticket"]["url"]
    }
  end
end
