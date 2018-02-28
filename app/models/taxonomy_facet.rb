class TaxonomyFacet < HiddenFacet
  include ActionView::Helpers::UrlHelper

  def value_fragments
    selected_values.map { |v|
      {
        'label' => link_to(v['label'], topic_page_url),
        'parameter_key' => key,
      }
    }
  end

  def topic_page_url
    %Q(#{ENV["TOPIC_PAGE_APP_URL"]}/#{value})
  end
end
