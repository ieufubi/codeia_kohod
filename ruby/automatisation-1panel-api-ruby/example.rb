require 'net/http'
require 'uri'
require 'json'

# Script autonome de vérification de santé pour 1Panel
# Ce script vérifie si le service Milvus répond sur son port
# après une tentative de redémarrage via l'API.

class ServiceHealthChecker
  def initialize(api_url, api_token)
    @uri = URI.parse(api_url)
    @token = api_token
  end

  def check_api_connectivity
    request = Net::HTTP::Get.new(