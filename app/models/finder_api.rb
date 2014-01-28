class FinderApi
  attr_reader :slug, :api

  def initialize(slug)
    @slug = slug
    # @api = FinderFrontend.finder_api
  end

  def get_schema
    {
      'slug' => 'cma-cases',
      'name' => 'Competition and Markets Authority cases',
      'facets' => [
        {
          'type' => 'select',
          'name' => 'Case type',
          'key' => 'case_type',
          'allowed_values' => [
            {'label' => 'Airport price control reviews',            'value' => 'airport-price-control-reviews'},
            {'label' => 'Market investigations',                    'value' => 'market-investigations'},
            {'label' => 'Remittals',                                'value' => 'remittals'},
            {'label' => 'Telecommunications price control appeals', 'value' => 'telecommunications-price-control-appeals'},
            {'label' => 'Energy code modification appeals',         'value' => 'energy-code-modification-appeals'},
            {'label' => 'Merger inquiries',                         'value' => 'merger-inquiries'},
            {'label' => 'Reviews of undertakings and orders',       'value' => 'reviews-of-undertakings-and-orders'},
            {'label' => 'Water price determinations',               'value' => 'water-price-determinations'}
          ],
          'include_blank' => 'All case types'
        }
      ]
    }
  end

  # def get_documents(params)
  #   api.get_documents(slug, params)
  # end
end
