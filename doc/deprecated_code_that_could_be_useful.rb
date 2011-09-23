  # From Slh::Models::Site
  # These nodes are extracted to create .metadata_site_specific_xml
  # and removed to create metadata_non_site_specific_nokogiri
  # which is used in Host to put the site specific crap below 1 instance of the non specific crap
  # so you can give your IDP one metadata file
  #
  # def self.metadata_site_specific_xpaths
  #   ['//md:ArtifactResolutionService', '//md:SingleLogoutService','//md:AssertionConsumerService']
  # end

  # def metadata_site_specific_xml
  #   if @metadata_site_specific_xml.blank?
  #     @metadata_site_specific_xml = ''
  #     self.class.metadata_site_specific_xpaths.each do |xpath|
  #       @metadata_site_specific_xml << self.metadata_nokogiri.xpath(xpath).to_a.join("\n")
  #       @metadata_site_specific_xml << "\n"
  #     end
  #   end
  #   @metadata_site_specific_xml
  # end

  # def metadata_non_site_specific_nokogiri
  #   if @metadata_non_site_specific_nokogiri.blank?
  #     @metadata_non_site_specific_nokogiri = self.metadata_nokogiri.clone
  #     self.class.metadata_site_specific_xpaths.each do |xpath|
  #       @metadata_non_site_specific_nokogiri.xpath(xpath).remove
  #     end
  #   end
  #   @metadata_non_site_specific_nokogiri
  # end


