""" python class generator """
# pylint: disable=line-too-long
import argparse
import os
import re
import glob
import yaml
import jinja2
import pylint.lint


TEMPLATE_FILE = 'class-template.tpl'


def handle_args() -> argparse.Namespace:
    """ handle command line arguments

    Returns:
        argparse.Namespace: the parsed arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', help='input glob', required=True)
    parser.add_argument('-o', '--output', help='output path', required=True)
    parser.add_argument('-f', '--force-output', help='overwrite existing output file', action='store_true')

    args = parser.parse_args()
    return args

def render_class(input_file, output_file):
    class_data = None
    # read in the class model yaml file
    print(f'reading next class file: {input_file}')
    with open(input_file, 'r', encoding='UTF-8') as file_handle:
        class_data = yaml.safe_load(file_handle)

    if 'class-data' not in class_data:  # pylint: disable=unsupported-membership-test
        raise RuntimeError('no class-data dict existing in class model')

    # setup jinja template engine
    template_loader = jinja2.FileSystemLoader(searchpath='.')
    # load loopcontrols extension to have break and continue in loop constructs
    template_env = jinja2.Environment(extensions=['jinja2.ext.loopcontrols'], loader=template_loader)
    # get the jinja template file
    template = template_env.get_template(TEMPLATE_FILE)

    # generate the base class module by converting base_class camel case to snake case
    if 'base_class' in class_data['class-data'] and class_data['class-data']['base_class'] is not None:
        class_data['class-data']['base_class_module'] = re.sub(r'(?<!^)(?=[A-Z])', '_', class_data['class-data']['base_class']).lower()

    # render the template
    data = template.render(**class_data['class-data'])

    # write rendered data to output file
    with open(output_file, 'w', encoding='UTF-8') as file_handle:
        file_handle.write(data)

    print('generated class:')
    print(data)
    print(f'created {class_data["class-data"]["name"]} class in {output_file}')

    print('running pylint check')
    ret = pylint.lint.Run([output_file], exit=False)
    if ret.linter.stats.global_note < 10.0:
        raise RuntimeError('class creation failed, pylint score below 10.0')
    print('pylint check successful')

def main():
    """ main """
    print('simple python class code generator v0.1')
    args = handle_args()

    input_files = glob.glob(args.input)
    for input_file in input_files:
        output_file = os.path.join(args.output, os.path.splitext(os.path.basename(input_file))[0] + '.py')
        if os.path.exists(output_file) and not args.force_output:
            raise RuntimeError(f'output file {output_file} already exists')
        render_class(input_file, output_file)


if __name__ == '__main__':
    main()
