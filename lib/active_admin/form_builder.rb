require 'formtastic'

module ActiveAdmin
  class FormBuilder < ::Formtastic::SemanticFormBuilder

    def datepicker_input(method, options)
      options = options.dup
      options[:input_html] ||= {}
      options[:input_html][:class] = [options[:input_html][:class], "datepicker"].compact.join(' ')
      options[:input_html][:size] ||= "10"
      string_input(method, options)
    end

    def has_many(association, options = {}, &block)
      options = { :for => association }.merge(options)
      options[:class] ||= ""
      options[:class] << "inputs has_many_fields"

      # Add Delete Links
      form_block = proc do |has_many_form|
        fields = template.capture(has_many_form, &block)
        delete = if has_many_form.object.new_record?
          template.content_tag :li do
            template.link_to I18n.t('active_admin.has_many_delete'), "#", :onclick => "$(this).closest('.has_many_fields').remove(); return false;", :class => "button"
          end
        else
        end

        fields + delete
      end

      template.content_tag :div, :class => "has_many #{association}" do
        buffer = "".html_safe
        buffer << template.content_tag(:h3, association.to_s.titlecase)
        buffer << inputs(options, &form_block)

        # Capture the ADD JS
        js = inputs_for_nested_attributes :for => [association, object.class.reflect_on_association(association).klass.new],
                                          :class => "inputs has_many_fields",
                                          :for_options => {
                                            :child_index => "NEW_RECORD"
                                          }, &form_block

        js = template.escape_javascript(js)
        js = template.link_to I18n.t('active_admin.has_many_new', :model => association.to_s.singularize.titlecase), "#", :onclick => "$(this).before('#{js}'.replace(/NEW_RECORD/g, new Date().getTime())); return false;", :class => "button"

        buffer << js
      end
    end

  end
end
