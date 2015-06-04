require 'cgi'

class HtmlInteractionDiagramCanvas
  def initialize(file_name)
    @file_name = file_name
  end

  def paint(interaction_diagram)
    File.open(@file_name, 'w') do |file|
      html = [@@header_html, CGI.escapeHTML(interaction_diagram.to_s), @@footer_html].join
      file.write html
    end
  end

  private

  @@header_html = <<END
<!DOCTYPE html>
<html>
<head>
    <title>Interaction Diagram</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/raphael/2.1.2/raphael-min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/js-sequence-diagrams/1.0.6/sequence-diagram-min.js"></script>
</head>
<body>
<div class="diagram">
END

  @@footer_html = <<END
</div>
<script>
    $(".diagram").sequenceDiagram({theme: 'simple'});
</script>
</body>
</html>
END

end
