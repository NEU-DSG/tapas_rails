class CollectionSearch < FortyFacets::FacetSearch
  model 'Collection'

  text :title
  text :description
  facet :depositor, name: 'Depositor'
  orders 'title' => :title,
         'time, newest first' => 'created_at desc',
         'time, oldest first' => 'created_at asc'
end
