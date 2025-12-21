ARG BASE_IMAGE=bde2020/spark-master:3.3.0-hadoop3.3
FROM ${BASE_IMAGE}

ARG HADOOP_AWS_VERSION=3.3.2
ARG AWS_SDK_BUNDLE_VERSION=1.11.901
ARG POSTGRES_JDBC_VERSION=42.7.4

ENV SPARK_EXTRA_JARS_DIR=/spark/jars

RUN set -eux; \
    mkdir -p "$SPARK_EXTRA_JARS_DIR" && \
    \
    curl -fSL "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar" \
      -o "${SPARK_EXTRA_JARS_DIR}/hadoop-aws-${HADOOP_AWS_VERSION}.jar" && \
    \
    curl -fSL "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_BUNDLE_VERSION}/aws-java-sdk-bundle-${AWS_SDK_BUNDLE_VERSION}.jar" \
      -o "${SPARK_EXTRA_JARS_DIR}/aws-java-sdk-bundle-${AWS_SDK_BUNDLE_VERSION}.jar" && \
    \
    curl -fSL "https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_JDBC_VERSION}/postgresql-${POSTGRES_JDBC_VERSION}.jar" \
      -o "${SPARK_EXTRA_JARS_DIR}/postgresql-${POSTGRES_JDBC_VERSION}.jar"
