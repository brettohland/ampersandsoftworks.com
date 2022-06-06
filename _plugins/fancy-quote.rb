module Jekyll
  class FancyQuote < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      text = super
      "#{@text} #{Time.now}"
    end
  end
end

Liquid::Template.register_tag('fancy-quote', Jekyll::FancyQuote)