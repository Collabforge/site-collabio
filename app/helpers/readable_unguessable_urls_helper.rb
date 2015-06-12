module ReadableUnguessableUrlsHelper
  MODELS_WITH_SLUGS = { 'discussion' => :title,
                              'user' => :name,
                            'group'  => :full_name,
                            'motion' => :name }
  MODELS_WITH_SLUGS.freeze

  ['user', 'motion'].each do |model|
    define_method("#{model}_url", ->(instance, options={}) {
      options = options.merge( host_and_port )
                       .merge( route_hash(instance, model) )

      url_for(options)
    })
  end

  def discussion_url(discussion, options = {})
    options = options.merge(host: host_for_group(discussion.group)).
                      merge(port: port).
                      merge(route_hash(discussion, 'discussion'))

    url_for(options)
  end

  def group_url(group, options = {})
    options = options.merge(host: host_for_group(group)).
                      merge(port: port).
                      merge(route_hash(group, 'group'))

    if group.has_subdomain? and not group.is_subgroup?
      uri = URI(url_for(options))
      uri.path = '/'
      uri.to_s
    else
      url_for(options)
    end
  end

  MODELS_WITH_SLUGS.keys.each do |model|
    define_method("#{model}_path", ->(instance, options={}) {
      self.send("#{model}_url", instance, options)
    })
  end

  private

  def host_for_group(group)
    host(group.subdomain)
  end

  def host(subdomain = nil)
    [subdomain || ENV['DEFAULT_SUBDOMAIN'], domain_and_tld].compact.join('.')
  end

  # for www.loomio.org this will return: loomio.org
  def domain_and_tld
    host = if request.present?
      request.host
    else
      ActionMailer::Base.default_url_options[:host]
    end
    host.split('.').last(tld_length.to_i + 1).join('.')
  end

  def subdomain
    request.subdomain
  end

  def tld_length
    ENV['TLD_LENGTH'] || "1"
  end

  def port
    if request.present?
      if using_default_port?
        nil
      else
        request.port
      end
    else
      ActionMailer::Base.default_url_options[:port]
    end
  end

  def using_default_port?
    (request.port == 80  && !request.ssl?) or (request.port == 443 && request.ssl?)
  end

  def route_hash(instance, model)
    controller = "/#{model.pluralize}"
    name = MODELS_WITH_SLUGS[model]
    slug = instance.send(name).parameterize

    { controller: controller, action: 'show', id: instance.key, slug: slug }
  end
end
