""" python class generator """
# pylint: disable=line-too-long
import argparse
import os
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
    parser.add_argument('-i', '--input', help='input yaml file', required=True)
    parser.add_argument('-o', '--output', help='output class file', required=True)
    parser.add_argument('-f', '--force-output', help='overwrite existing output file', action='store_true')

    args = parser.parse_args()
    return args

def main():
    """ main """
    print('simple python class code generator v0.1')
    args = handle_args()

    # test if output file already exists, skip if --force-output is set
    if os.path.exists(args.output) and not args.force_output:
        raise RuntimeError('output file already exists')

    class_data = None
    # read in the class model yaml file
    with open(args.input, 'r', encoding='UTF-8') as file_handle:
        class_data = yaml.safe_load(file_handle)

    if 'class-data' not in class_data:  # pylint: disable=unsupported-membership-test
        raise RuntimeError('no class-data dict existing in class model')

    # setup jinja template engine
    template_loader = jinja2.FileSystemLoader(searchpath='.')
    # load loopcontrols extension to have break and continue in loop constructs
    template_env = jinja2.Environment(extensions=['jinja2.ext.loopcontrols'], loader=template_loader)
    # get the jinja template file
    template = template_env.get_template(TEMPLATE_FILE)
    # render the template
    data = template.render(**class_data['class-data'])

    # write rendered data to output file
    with open(args.output, 'w', encoding='UTF-8') as file_handle:
        file_handle.write(data)

    print('generated class:')
    print(data)
    print(f'created {class_data["class-data"]["name"]} class in {args.output}')

    print('running pylint check')
    ret = pylint.lint.Run([args.output], exit=False)
    if ret.linter.stats.global_note < 10.0:
        raise RuntimeError('class creation failed, pylint score below 10.0')
    print('pylint check successful')

if __name__ == '__main__':
    main()
