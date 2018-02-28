class TaxonomyFinderApi < FinderApi
  def content_item_with_search_results
    @taxon = fetch_taxon
    filter_params['taxons'] = taxon['content_id']
    content_item = fetch_content_item

    # FIXME: This can be replaced by a hidden facet once
    # we can use content_purpose_supergroups/subgroups
    if document_type = filter_params.delete('content_purpose_document_supertype')
      filter_params['format'] = [document_type]
    end

    search_response = fetch_search_response(content_item)
    augment_content_item_with_results(content_item,search_response)
  end

private

  attr_reader :taxon

  def fetch_taxon
    # TODO: Rescue 404s
    Services.content_store.content_item(filter_params.delete('taxons'))
  end

  def fetch_content_item
    if Rails.env.test?
      super
    else
      JSON.parse(File.read("all-finder.json")) # FIXME: use ENV var or content item.
    end
  end

  def augment_facets_with_dynamic_values(content_item, _)
    facet = content_item['details']['facets'].find { |f| f['key'] == 'taxons' }
    facet['allowed_values'] = [{'label' => taxon['title'], 'value' => taxon['base_path'] }]
  end
end
