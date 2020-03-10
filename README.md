# Convenience tools to run Apache Crail

This is a small collection of scripts to run and stop Apache Crail.

## Running Apache Crail from a development source tree

If you check out the [Apache Crail](http://crail.apache.org/) [source code](https://github.com/apache/incubator-crail)
for development (or just to try out), you sometimes want to quickly start it to run a small test.
The script `run_crail_from_devsrc.sh` is an easy way to just run Apache Crail from your source tree.

### Check out the tools repository and the Apache Crail source code
First, check out this repository into your working directory

    git clone https://github.com/asqasq/tools
    
Then, check out the source code of Apache Crail

    git clone https://github.com/apache/incubator-crail

### Compile Apache Crail
Change to the Apache Crail directory and compile it

    cd incubator-crail
    mvn -DskipTests package

### Run and stop Apach Crail from your source directory
Now you are ready to run a Apache Crail instance from you source directory. Make sure to not forget the dot `.`
in front of the command line, which basically means that the script gets sourced and `CRAIL_HOME` and `PATH` to
Crail binaries get exported.

    . ../tools/run_crail_from_devsrc.sh

If you want to stop Apache Crail again, simply run the `kill_crail.sh` script

    ../tools/kill_crail.sh

If you get an error message, like:

    ../tools/kill_crail.sh: line 4: kill: (22222) - No such process
    ../tools/kill_crail.sh: line 5: kill: (22223) - No such process

Don't worry, these are the PIDs of grep, which is finding itself.
