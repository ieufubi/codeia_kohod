require 'httpx'
require 'json'

# Simulation d'un parseur robuste pour ezbookkeeping MCP Xiaohongshu
class XiaohongshuExtractor
  def initialize(url)
    @url = url
  end

  def run
    puts "[INFO] D\u00e9but de l'extraction pour : #{@url}"
    
    # Simulation d'une r\u00e9ponse HTML contenant du JSON
    html_payload = <<~HTML
      <html>
        <body>
          <script>
            window.__INITIAL_STATE__ = {
              "post_id": "xh_98765",
              "content": {"title": "Ruby est incroyable !", "likes": 450}
            };
          </script>
        </body>
      </html>
    HTML

    parse(html_payload)
  rescue StandardError => e
    puts "[ERREUR] #{e.message}"
  end

  private

  def parse(html)
    # Utilisation du pattern matching pour extraire les données du script
    # On cherche la structure JSON dans la balise script
    case html
    in /"post_id":\s*"(?<id>[^"]+)".*?"title":\s*"(?<title>[^"]+)".*?"likes":\s*(?<likes>\d+)/m
      {
        id: $~[:id],
        title: $~[:title],
        likes: $~[:likes].to_i,
        timestamp: Time.now.to_i
      }
    else
      raise "Impossible de parser le contenu : format inconnu ou structure modifi\u00e9e."
    end
  end
end

# Ex\u00e9cution du script
extractor = XiaohongshuExtractor.new("https://www.xiaohongshu.com/explore/xh_98765")
result = extractor.run

if result
  puts "[RESULTAT MCP]"
  puts JSON.pretty_generate(result)
else
  puts "[ECHEC] Aucun objet n'a pu \u00e9t\u00e9 extrait."
end