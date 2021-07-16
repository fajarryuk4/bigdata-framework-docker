from pyspark.sql import SparkSession
from pyspark.sql.types import StringType

class pysparklib:
    def __init__(self, app_name):
        self.spark = (SparkSession
            .builder
            .master('local')
            .appName(app_name)
            .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.1")
            .getOrCreate()
        )
    
    def read_csv_dataset(self, path, header, inferSchema):
        self.dataset = self.spark.read.csv(path, header, inferSchema)

    def get_spark_context(self):
        self.sc = self.spark.sparkContext
        return self.sc

    def kafkaStreamDF(self, bootstrap_server, topic):
        self.dataframe = (self.spark
            .readStream
            .format("kafka")
            .option("kafka.bootstrap.servers", bootstrap_server) # kafka server
            .option("subscribe", topic) # topic
            .option("startingOffsets", "earliest") # start from beginning 
            .load()
        )
    
    def kafka_converter(self):
        self.key_converter = self.dataframe["key"].cast(StringType())
        self.value_converter = self.dataframe["value"].cast(StringType())
        self.kafka_converter = (
            self.dataframe
            .withColumn("key", self.key_converter)
            .withColumn("value", self.value_converter)
        )

        return self.kafka_converter
