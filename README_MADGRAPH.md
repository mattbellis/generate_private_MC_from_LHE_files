Link to bnv-ufo from MG5

Link to madgraph_scripts from MG5

Link to run_all.sh from MG5

https://answers.launchpad.net/mg5amcnlo/+faq/1943

In order to forbid the opening the web browser, you need to modify the file
MG5_DIR/input/mg5_configuration.txt
(or ./Cards/me5_configuration.txt)

    and put the line:
# Allow/Forbid the automatic opening of the web browser (on the
        status page)
#when launching MadEvent [True/False]
automatic_html_opening = False


Edit aloha/create_aloha.py to comment out error about 4pt interactions. 

if not data == target:
    text = """Unable to deal with 4(or more) point interactions
    in presence of majorana particle/flow violation"""
    #raise ALOHAERROR, text

