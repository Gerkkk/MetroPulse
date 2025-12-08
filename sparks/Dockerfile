# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM apache/spark:4.0.0
USER root

RUN mkdir /artifacts
RUN mkdir -p /tmp/ivy_cache &&  mkdir -p /tmp/spark_local
ENV IVY_CACHE_DIR /tmp/ivy_cache
ENV SPARK_LOCAL_DIRS /tmp/spark_local
ENV _JAVA_OPTIONS "-Duser.home=/tmp"
RUN chown -R spark ${SPARK_LOCAL_DIRS}
RUN chown -R spark /artifacts

ENV LD_LIBRARY_PATH /opt/hadoop/lib/native/

USER spark

ENV SPARK_PACKAGES ""
ENV CONFIG /opt/spark/config.cfg
ENV MAIN_SCRIPT /opt/spark/scripts/main.py

WORKDIR /

ARG PREINSTALLED_PACKAGES ""
RUN touch ${SPARK_LOCAL_DIRS}/dummy.py
RUN if [ "${PREINSTALLED_PACKAGES}" != '""' ]; then \ 
        ./opt/spark/bin/spark-submit --packages $PREINSTALLED_PACKAGES ${SPARK_LOCAL_DIRS}/dummy.py; \
    fi

CMD ./opt/spark/bin/spark-submit --packages $SPARK_PACKAGES --properties-file $CONFIG $MAIN_SCRIPT