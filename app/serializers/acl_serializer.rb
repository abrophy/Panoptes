module ACLSerializer
  extend ActiveSupport::Concern

  include RestPack::Serializer

  module ClassMethods
    def key
      @key
    end

    def model_class
      AccessControlList
    end

    def links
      links = super
      links.delete("#{key}.user_group")
      link_type = resource_type.pluralize
      links["#{key}.#{resource_type}"] = { type: link_type,
                                           href: "/#{link_type}/{#{key}.#{resource_type}}" }
      links["#{key}.owner"] = { type: "owners",
                                href: "/{#{key}.owner.href}/{#{key}.owner.id}" }
      links
    end
  end

  def add_links(model, data)
    data = super(model, data)
    data[:links][self.class.resource_type] = data[:links][:resource][:id]
    data[:links].delete(:resource)
    group = model.user_group
    group = group.users.first if group.identity?
    data[:links][:owner] = { id: group.id.to_s,
                             type: group.class.model_name.plural,
                             href: group.class.model_name.route_key}
    data
  end
end
