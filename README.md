# simple python class generator
a very simple template based python class code generator

## what does it do
create python class files from a yaml class description file.

## how does it work
renders the output file using a jinja2 template. automatically runs pylint at the end to make sure code is ok.

## how to use it
to install the required dependencies:
```
pip3 install -r requirements.txt
```

to render a yaml file:
```
python3 classgen.py -i examples/\*.yaml -o generated/
```

for further options see: `python3 classgen.py --help`.
