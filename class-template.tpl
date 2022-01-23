""" {% if description %}{{ description }}{% else %}class implementation{% endif %} """


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
    ):{% if fields|length > 5 %}  # pylint: disable=too-many-arguments{% endif %}
    {%- for field in fields: -%}
    {%- if 'kwarg' not in fields[field] or fields[field].kwarg == False %}
    {%- if init_with_setter %}
        self.set_{{ field }}({{ field }})
    {%- else %}
        self.__{{ field }} = {{ field }}
    {%- endif -%}
    {%- endif -%}
    {%- endfor %}
{%- for field in fields: -%}
{%- if fields[field].kwarg == True %}
    {%- if init_with_setter %}
        self.set_{{ field }}(kwargs.get('{{ field }}', {{ fields[field].default }}))
    {%- else %}
        self.__{{ field }} = kwargs.get('{{ field }}', {{ fields[field].default }})
    {%- endif -%}
{%- endif -%}
{%- endfor %}
{% for field in fields: %}
    def get_{{ field }}(self){% if fields[field].datatype %} -> {{ fields[field].datatype }}{% endif %}:
        """ getter for {{ field }}

        Returns:
            {% if fields[field].datatype %}{{ fields[field].datatype }}{% else %}[type]{% endif %}: {% if 'description' in fields[field] %}{{ fields[field].description }}{% else %}[description]{% endif %}
        """
        return self.__{{ field }}
{% endfor -%}
{% for field in fields: %}
    def set_{{ field }}(self, {{ field }}{% if fields[field].datatype %}: {{ fields[field].datatype }}{% endif %}):
        """ setter for {{ field }}

        Args:
            {{field}} ({% if fields[field].datatype %}{{ fields[field].datatype }}{% else %}[type]{% endif %}): {% if 'description' in fields[field] %}{{ fields[field].description }}{% else %}[description]{% endif %}
        """
        self.__{{ field }} = {{ field }}
{% endfor -%}