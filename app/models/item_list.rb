class ItemList < ActiveRecord::Base
  belongs_to :user

  attr_accessible :name, :id, :user_id

  validates :name, presence: true

  #
  # Class variables for information about Solr
  #
  @@solr_config = nil
  @@solr = nil

  #
  # Initialise the connection to Solr
  #
  def get_solr_connection
    if @@solr_config.nil?
      @@solr_config = Blacklight.solr_config
      @@solr        = RSolr.connect(@@solr_config)
    end
  end

  #
  # Get the list of Item ids which this ItemList contains.
  # Return an array of Strings.
  #
  def get_item_ids
    get_solr_connection

    # The query is: give me items which have my item_list.id in their item_lists field
    params = {:start=>0, :q=>"item_lists:#{RSolr.escape(id.to_s)}", :fl=>"id"}
    max_rows = 100

    # First stab at the query
    params[:rows] = max_rows
    response = @@solr.get('select', params: params)

    # If there are more rows in Solr than we asked for, increase the number we're
    # asking for and ask for them all this time. Sadly, there doesn't appear to be
    # a "give me everything" value for the rows parameter.
    if response["response"]["numFound"] < max_rows
        params[:rows] = response["response"]["numFound"]
        response = @@solr.get('select', params: params)
    end

    # Now extract the ids from the response
    return response["response"]["docs"].map { |thingy| thingy["id"] }.sort
  end

  #
  # Query Solr for all the Solr Documents describing the constituent
  # Items of this ItemList.
  # Return the response we get from Solr.
  #
  def get_items(start = 0, rows = 20)
    get_solr_connection

    params = {:start=>start, :rows => rows, :q=>"item_lists:#{RSolr.escape(id.to_s)}"}

    solrResponse = @@solr.get('select', params: params)
    response = Blacklight::SolrResponse.new(force_to_utf8(solrResponse), params)

    return response
  end
  
  #
  # Add some Items to this ItemList. The Items should be specified by
  # their ids. Don't add an Item which is already part of this ItemList.
  # Return a Set of the ids of the Items which were added.
  #
  def add_items(item_ids)
    adding = Set.new(item_ids.map{ |item_id| item_id.to_s })
    adding.subtract(get_item_ids)

    # The variable adding now contains only the new ids

    adding.each { |item_id|
        # Get the specified Item's Solr Document
        params = {:q=>"id:#{RSolr.escape(item_id.to_s)}"}
        response = @@solr.get('select', params: params)

        # Check that we got something useful...
        if response == nil 
            logger.warning "No response from Solr when searching for Item #{item_id}"
        elsif response["response"] == nil
            logger.warning "Badly formed response from Solr when searching for Item #{item_id}"
        elsif response["response"]["numFound"] == 0
            logger.warning "Cannot find Item #{item_id} in Solr"
        elsif response["response"]["numFound"] > 1
            logger.warning "Multiple documents for Item #{item_id} in Solr"
        else
            #... and if we did, update it
            update_solr_field(item_id, :item_lists, id)
        end
    }

    return adding
  end
  
  #
  # Add the contents of item_list to this ItemList.
  #
  def add_item_list(item_list)
    return add_items(get_item_ids)
  end
  
  #
  # Remove some Items from this ItemList. The Items should be specified by
  # their ids. Return a Set of the ids of the Items which were removed.
  #
  def remove_items(item_ids)
    item_ids = [item_ids] if item_ids.is_a?(String)
    removing = Set.new(item_ids.map{ |item_id| item_id.to_s }) & get_item_ids

    removing.each { |item_id|
        # Get the specified Item's Solr Document
        params = {:q=>"id:#{RSolr.escape(item_id.to_s)}"}
        response = @@solr.get('select', params: params)

        # Check that we got something useful...
        if response == nil 
            logger.warning "No response from Solr when searching for Item #{item_id}"
        elsif response["response"] == nil
            logger.warning "Badly formed response from Solr when searching for Item #{item_id}"
        elsif response["response"]["numFound"] == 0
            logger.warning "Cannot find Item #{item_id} in Solr"
        elsif response["response"]["numFound"] > 1
            logger.warning "Multiple documents for Item #{item_id} in Solr"
        else
            #... and if we did, remove the our id from the Item's Solr
            # Document's item_lists field. Solr doesn't give us an
            # inverse to the 'add' operation we use in add_items(), and
            # 'set'ting with an array doesn't want to play, so
            # we reset the field to an empty array (with a 'set') and
            # then iterate over each value 'add'ing in the value. Empty
            # lists are wee bastards which I fake by using a list with
            # a single, unused ItemList id in ('.').

            document = response["response"]["docs"][0]
            current_ids = document["item_lists"]
            current_ids.delete('.')
            current_ids.delete(id.to_s)

            if current_ids.empty?
                clear_solr_field(item_id, :item_lists)
            else
                udpate_solr_field(item_id, :item_lists, current_ids[0], 'set')
                current_ids[1..-1].each { |current_id|
                    udpate_solr_document(item_id, :item_lists, current_id, 'add')
                }
            end
        end
    }

    return removing
  end
  
  #
  # Remove all Items from this ItemList.
  #
  def clear()
    return remove_items(get_item_ids)
  end

  private

  def update_solr_field(item_id, field_id, field_value, mode='add')
    doc1 = {:id => item_id, field_id => field_value}
    add_attributes = {:allowDups => false, :commitWithin => 10}

    xml_update = @@solr.xml.add(doc1, add_attributes) do |doc2|
        doc2.field_by_name(field_id).attrs[:update] = mode
    end

    @@solr.update :data => xml_update
  end

  def clear_solr_field(item_id, field_id)
    # TODO: ermm, this, properly (see http://wiki.apache.org/solr/UpdateXmlMessages#Optional_attributes_for_.22field.22
    # and https://github.com/mwmitchell/rsolr)
    udpate_solr_field(item_id, field_id, '.', 'set')
  end


  def force_to_utf8(value)
    case value
      when Hash
        value.each { |k, v| value[k] = force_to_utf8(v) }
      when Array
        value.each { |v| force_to_utf8(v) }
      when String
        value.force_encoding("utf-8")  if value.respond_to?(:force_encoding)
    end
    value
  end

end