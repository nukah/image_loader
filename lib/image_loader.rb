require 'logger'

class ImageLoader
  attr_reader :url, :logger

  def initialize(url, logger = Logger.new(STDOUT))
    @logger = logger
    @url = url
  end

  def save
    raise RuntimeError.new('URL is invalid!') unless url_valid?
    logger.info("Starting to process images for #{host}")

    page_image_paths.each do |path|
      name = File.basename(URI(path).path)
      request = Typhoeus::Request.new(path)
      request.on_complete do |response|
        File.open(File.join(page_directory, name), 'w') do |file|
          file.write(response.body)
          log(name)
        end
      end
      hydra.queue(request)
    end
    hydra.run
  end

  private

  def log(name)
    logger.info("Processing image: #{name}")
  end

  def url_valid?
    (url =~ URI::regexp) != nil
  end

  def image_valid?(path)
    mime_magic = MimeMagic.by_path(path)
    mime_magic && mime_magic.image?
  end

  def page
    @page ||= Nokogiri::HTML(Typhoeus.get(url, followlocation: true).body)
  end

  def page_image_paths
    @page_image_paths ||= page.xpath('//img/@src').map(&:value).select do |path|
      image_valid?(path)
    end
  end

  def host
    URI(url).host
  end

  def hydra
    @hydra ||= Typhoeus::Hydra.new(max_concurrency: 10)
  end

  def page_directory
    Dir.mkdir(host) unless File.exists?(host)
    File.absolute_path(host)
  end
end
