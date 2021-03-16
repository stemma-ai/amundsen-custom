# Installation

## Bootstrap a default version of Amundsen using Docker
The following instructions are for setting up a version of Amundsen using Docker, backed by Neo4j and Elasticsearch.

1. Create a [private fork](https://gist.github.com/0xjac/85097472043b697ab57ba1b1c7530274) of this repo.
1. Clone your fork [this repo](https://github.com/stemma-ai/amundsen-custom) and its submodules by running:
   ```bash
   git clone --recursive git@github.com:stemma-ai/amundsen-custom.git
   ```
1. Install `docker` and  `docker-compose`. *Allocate at least 3GB available to Docker.*
1. Enter the cloned directory and run:
    ```bash
    docker-compose -f docker-compose.yml up
    ```
1. Ingest static sample data into Neo4j:
   * In a separate terminal window, `cd` to the [databuilder/upstream](https://github.com/amundsen-io/amundsendatabuilder) submodule.
   * The `sample_data_loader.py` Python script included in `examples/` directory uses _elasticsearch client_, _pyhocon_ and other libraries. Install the dependencies in a virtual env and run the script by following the commands below:
   ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
    python3 setup.py install
    python3 example/scripts/sample_data_loader.py
   ```
1. View UI at [`http://localhost:5000`](http://localhost:5000) and try to search `test`, it should return some results.

### Verify setup

1. You can verify dummy data has been ingested into Neo4j by by visiting [`http://localhost:7474/browser/`](http://localhost:7474/browser/) and run `MATCH (n:Table) RETURN n LIMIT 25` in the query box. You should see two tables:
   1. `hive.test_schema.test_table1`
   1. `hive.test_schema.test_table2`
![](img/neo4j-debug.png)
1. You can verify the data has been loaded into the metadataservice by visiting:
   1. [`http://localhost:5000/table_detail/gold/hive/test_schema/test_table1`](http://localhost:5000/table_detail/gold/hive/test_schema/test_table1)
   2. [`http://localhost:5000/table_detail/gold/dynamo/test_schema/test_table2`](http://localhost:5000/table_detail/gold/dynamo/test_schema/test_table2)


### Troubleshooting
1. If the Docker Container doesn't have enough heap memory for Elastic Search, `es_amundsen` will with the error `es_amundsen | [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]`
   1. Increase the Heap memory in the host machine. In Linux, that means modifying your own machine. For Mac, that means modifying the Docker for Mac configuration. [See these detailed instructions from Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/7.1/docker.html#docker-cli-run-prod-mode).
   2. Re-run `docker-compose`

2. If `docker-compose` stops with a `org.elasticsearch.bootstrap.StartupException: java.lang.IllegalStateException: Failed to create node environment` message, then `es_amundsen` [cannot write](https://discuss.elastic.co/t/elastic-elasticsearch-docker-not-assigning-permissions-to-data-directory-on-run/65812/4) to `.local/elasticsearch`. There is a file share mount established between the Docker container and your host machine, so run this in your terminal:
   1. `chown -R 1000:1000 .local/elasticsearch`
   2. Re-reun `docker-compose`

3. If ES container crashed with Docker error 137 on the first call from the website (http://localhost:5000/), this is because you are using the default Docker engine memory allocation of 2GB. The minimum needed for all the containers to run with the loaded sample data is 3GB. To do this go to your `Docker -> Preferences -> Resources -> Advanced` and increase the `Memory`, then restart the Docker engine.

4. Check if all 5 Amundsen related containers are running with `docker ps`? Can you connect to the Neo4j UI at http://localhost:7474/browser/ and similarly the raw ES API at http://localhost:9200? Does Docker logs reveal any notable issues?

5. [Report the issue](https://github.com/stemma-ai/amundsen-custom/issues) on this repo. The standard instructions should Just Work for everyone, and we'll gladly help get your install working!
