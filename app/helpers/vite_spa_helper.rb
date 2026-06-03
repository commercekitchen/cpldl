module ViteSpaHelper
  def vite_spa_tags
    manifest_path = Rails.public_path.join('spa/.vite/manifest.json')
    raise "Vite manifest missing: #{manifest_path}. Run `npm run build` in frontend/" unless File.exist?(manifest_path)

    manifest = JSON.parse(File.read(manifest_path))

    # Default Vite entry is usually "index.html" in the manifest
    entry = manifest['index.html']
    raise "Vite manifest has no 'index.html' entry" unless entry

    tags = +''

    # CSS first
    Array(entry['css']).each do |css|
      tags << stylesheet_link_tag("/spa/#{css}", media: 'all')
    end

    # JS entry
    file = entry['file']
    tags << javascript_include_tag("/spa/#{file}", type: 'module')

    # Preload imports (optional but nice)
    Array(entry['imports']).each do |import_key|
      import_entry = manifest[import_key]
      next unless import_entry&.dig('file')

      tags << tag.link(rel: 'modulepreload', href: "/spa/#{import_entry['file']}")
    end

    tags.html_safe # rubocop:disable Rails/OutputSafety
  end
end
