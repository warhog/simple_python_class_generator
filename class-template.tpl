{% macro protected_private(field) %}{% if field.protected and field.protected == True %}_{% else %}__{% endif %}{% endmacro -%}

""" {% if description %}{{ description }}{% else %}class implementation{% endif %} """
# pylint: disable=line-too-long
{% if base_class %}from {{ base_class_module }} import {{ base_class }}{% endif %}

class {{ name }}{% if base_class %}({{ base_class }}){% endif %}:
    """ {% if description %}{{ description }}{% else %}class implementation{% endif %} """
    def __init__(self{%- for field in fields: -%}
        {%- if 'kwarg' not in fields[field] or fields[field].kwarg == False -%}
            , {{ field }}{% if fields[field].datatype %}: {{ fields[field].datatype }}{% endif %}{% if fields[field].default %}={{ fields[field].default }}{% endif %}
        {%- endif -%}
    {%- endfor -%}
    {%- for field in fields: -%}
    {%- if 'kwarg' in fields[field] and fields[field].kwarg == True -%}
    , **kwargs
    {%- break -%}
    {%- endif -%}
    {%- endfor -%}
    ):{% if fields|length > 5 %}  # pylint: disable=too-many-arguments{% endif %}{% if base_class %}  # pylint: disable=super-init-not-called{% endif %}
    {%- if base_class %}
        # TODO add parameters for base class  # pylint: disable=fixme
        # super().__init__()
    {%- endif -%}
    {%- for field in fields: -%}
    {%- if 'kwarg' not in fields[field] or fields[field].kwarg == False %}
    {%- if init_with_setter %}
        self.set_{{ field }}({{ field }})
    {%- else %}
        self.{{ protected_private(fields[field]) }}{{ field }} = {{ field }}
    {%- endif -%}
    {%- endif -%}
    {%- endfor %}
{%- for field in fields: -%}
{%- if fields[field].kwarg == True %}
    {%- if init_with_setter %}
        self.set_{{ field }}(kwargs.get('{{ field }}'{% if fields[field].default %}, {{ fields[field].default }}{% endif %}))
    {%- else %}
        self.{{ protected_private(fields[field]) }}{{ field }} = kwargs.get('{{ field }}'{% if fields[field].default %}, {{ fields[field].default }}{% endif %})
    {%- endif -%}
{%- endif -%}
{%- endfor %}
{% for field in fields: %}
    def get_{{ field }}(self){% if fields[field].datatype %} -> {{ fields[field].datatype }}{% endif %}:
        """ getter for {{ field }}

        Returns:
            {% if fields[field].datatype %}{{ fields[field].datatype }}{% else %}[type]{% endif %}: {% if 'description' in fields[field] %}{{ fields[field].description }}{% else %}[description]{% endif %}
        """
        return self.{{ protected_private(fields[field]) }}{{ field }}
{% endfor -%}
{% for field in fields: %}
    def set_{{ field }}(self, {{ field }}{% if fields[field].datatype %}: {{ fields[field].datatype }}{% endif %}):
        """ setter for {{ field }}

        Args:
            {{field}} ({% if fields[field].datatype %}{{ fields[field].datatype }}{% else %}[type]{% endif %}): {% if 'description' in fields[field] %}{{ fields[field].description }}{% else %}[description]{% endif %}
        """
        self.{{ protected_private(fields[field]) }}{{ field }} = {{ field }}
{% endfor %}
    def __repr__(self):
        return f'{{ name }}{% raw %}{{{% endraw %}{% for field in fields %}{{ field }}={self.{{ protected_private(fields[field]) }}{{ field }}}, {% endfor %}}}'

