# MetroPulse

Аналитическая платформа для сервиса отслеживания общественного транспорта в реальном времени.

## Архитектура

### Общая схема системы

```mermaid
graph TB
    subgraph Sources["ИСТОЧНИКИ ДАННЫХ"]
        Backend[Backend Generator Go]
        OLTP[(PostgreSQL OLTP)]
        Backend -->|Записывает данные| OLTP
        Backend -->|Регулярные события| Kafka
    end

    subgraph CDC["CDC & ИНТЕГРАЦИЯ"]
        Debezium[Debezium CDC]
        OLTP -->|Change Data Capture| Debezium
        Debezium -->|CDC события| Kafka
    end

    subgraph RawLayer["СЛОЙ СЫРЫХ ДАННЫХ"]
        MinIO[MinIO S3 Storage]
    end

    subgraph ETL["ОБРАБОТКА ДАННЫХ"]
        SparkWorkers[Spark Workers]
    end

    subgraph DWH["DATA WAREHOUSE"]
        GP[(Greenplum DWH Data Vault 2.0)]
        
        subgraph DVStructure["Data Vault структура"]
            Hubs[HUBS: H_USERS, H_POSITIONS, H_ROUTES, H_VEHICLES, H_RIDES, H_PAYMENTS]
            Links[LINKS: L_ROUTE_VEHICLE, L_USER_PAYMENT, L_RIDE_ROUTE, L_RIDE_PAYMENT, L_RIDE_VEHICLE, L_RIDE_USER, L_POSITION_VEHICLE]
            Satellites[SATELLITES: S_USERS, S_ROUTES, S_VEHICLES, S_RIDES, S_PAYMENTS, S_POSITIONS]
        end
        
        GP -.->|Содержит| Hubs
        GP -.->|Содержит| Links
        GP -.->|Содержит| Satellites
    end

    subgraph Marts["АНАЛИТИЧЕСКИЕ ВИТРИНЫ"]
        CH[(ClickHouse OLAP)]
    end

    Kafka ==>|Spark читает из Kafka| SparkWorkers
    
    SparkWorkers ==>|Spark записывает Parquet| MinIO
    
    MinIO ==>|Spark читает Parquet| SparkWorkers
    SparkWorkers ==>|Spark загружает данные| GP
    
    GP ==>|Spark читает для агрегации| SparkWorkers
    SparkWorkers ==>|Spark загружает агрегированные данные| CH
```

### Поток данных

```mermaid
flowchart LR
    subgraph Sources["ИСТОЧНИКИ ДАННЫХ"]
        Backend[Backend Generator]
        OLTP[(PostgreSQL OLTP)]
    end

    subgraph Streaming["STREAMING"]
        Kafka[Apache Kafka]
    end

    subgraph CDC["CDC"]
        Debezium[Debezium CDC]
    end

    subgraph RawLayer["СЛОЙ СЫРЫХ ДАННЫХ"]
        MinIO[MinIO S3 Storage]
    end

    subgraph Processing["ОБРАБОТКА ДАННЫХ"]
        Spark[Apache Spark]
    end

    subgraph DWH["DATA WAREHOUSE"]
        GP[(Greenplum Data Vault 2.0)]
    end

    subgraph Marts["АНАЛИТИЧЕСКИЕ ВИТРИНЫ"]
        CH[(ClickHouse OLAP)]
    end

    Backend -->|Транзакции| OLTP
    Backend -->|События| Kafka
    
    OLTP -->|CDC| Debezium
    Debezium -->|CDC события| Kafka
    
    Kafka ==>|Spark читает из Kafka| Spark
    
    Spark ==>|Spark записывает Parquet| MinIO
    
    MinIO ==>|Spark читает Parquet| Spark
    
    Spark ==>|Spark загружает с SCD Type 2| GP
    
    GP ==>|Spark читает для агрегации| Spark
    
    Spark ==>|Spark загружает витрины| CH
```

### Data Vault 2.0 структура

![DWH Schema](docs/dwh.png)

## Источники данных

```mermaid
erDiagram
    USERS ||--o{ RIDES : makes
    USERS ||--o{ PAYMENTS : pays
    ROUTES ||--o{ VEHICLES : has
    ROUTES ||--o{ RIDES : uses
    VEHICLES ||--o{ RIDES : transports
    RIDES ||--o| PAYMENTS : paid_by
    
    USERS {
        int user_id PK
        string name
        string email
        timestamp created_at
        string city
    }
    
    ROUTES {
        int route_id PK
        string route_number
        string vehicle_type
        decimal base_fare
    }
    
    VEHICLES {
        int vehicle_id PK
        int route_id FK
        string licence_plate
        int capacity
    }
    
    RIDES {
        uuid ride_id PK
        int user_id FK
        int route_id FK
        int vehicle_id FK
        timestamp start_time
        timestamp end_time
        decimal fare_amount
    }
    
    PAYMENTS {
        uuid payment_id PK
        uuid ride_id FK
        int user_id FK
        decimal amount
        string payment_method
        string status
        timestamp created_at
    }
    
    VEHICLE_POSITIONS {
        string event_id PK
        int vehicle_id
        string route_number
        timestamp event_time
        float latitude
        float longitude
        float speed_kmh
        int passengers_estimated
    }
```

**PostgreSQL OLTP** - транзакционные данные (USERS, ROUTES, VEHICLES, RIDES, PAYMENTS)

**Kafka Topic: vehicle_positions** - потоковые события от транспорта (VEHICLE_POSITIONS)


## Обоснование выбора технологий

### PostgreSQL (OLTP)
- Гарантия целостности данных для транзакций
- Проверенное решение для OLTP-нагрузок

### Apache Kafka
- Высокая пропускная способность
- Репликация и устойчивость к сбоям
- Горизонтальное масштабирование
- Нативная поддержка Debezium и Spark

### Debezium CDC
- Все INSERT/UPDATE/DELETE сохраняются и могут быть использованы для аналитики

### MinIO
- Стандартный S3 API для работы с объектами
- Open source

### Apache Spark
- Eдиный движок для всех ETL операций
- Горизонтальное масштабирование
- Нативная поддержка Kafka, S3, PostgreSQL, Greenplum
- Встроенные возможности для отслеживания истории

### Greenplum (DWH)
- Параллельная обработка запросов
- Оптимизация для аналитических запросов
- Эффективная работа с большими объемами

### ClickHouse (OLAP)
- На порядки быстрее традиционных СУБД
- Оптимизация для агрегаций
- Эффективное использование дисков
- Горизонтальное масштабирование
- Поддержка всех популярных инструментов

### Data Vault 2.0
- Легко добавлять новые источники данных
- Полная история изменений (load_date, load_source)
- Подходит для больших и сложных систем

## Обоснование выбора методологии моделирования

### Kimball vs Data Vault 2.0

| Критерий | Kimball (Star Schema) | Data Vault 2.0 | Выбор |
|----------|----------------------|----------------|-------|
| **Гибкость** | Сложно добавлять источники | Легко добавлять источники | DV |
| **История изменений** | SCD Type 2 в измерениях | Встроенная в Satellites | DV |
| **Скорость разработки** | Быстрее для простых схем | Медленнее на старте | Kimball |
| **Производительность запросов** | Оптимизирована для BI | Требует витрин | Kimball |
| **Масштабируемость** | Ограничена | Высокая | DV |
| **Аудит данных** | Ограниченный | Полный (load_date, load_source) | DV |
| **Параллельная загрузка** | Зависимости между таблицами | Независимые Hubs/Links/Satellites | DV |

По итогу был выбран Data Vault 2.0, так как он подходит для больших и сложных систем, а также позволяет легко добавлять новые источники данных.

## Реализация SCD Type 2

Debezium используется для захвата изменений из PostgreSQL OLTP в реальном времени. Он читает Write-Ahead Log (WAL) PostgreSQL и публикует все операции INSERT/UPDATE/DELETE как события в Kafka топики (users_cdc, routes_cdc, vehicles_cdc, rides_cdc, payments_cdc). Это позволяет получать изменения без нагрузки на OLTP базу и обеспечивает полную историю всех модификаций данных для последующей обработки в Spark и загрузки в Data Vault с сохранением временных меток и источника изменений.

SCD Type 2 реализован в Satellites таблицах (S_USERS, S_ROUTES, S_VEHICLES) для отслеживания исторических изменений. При изменении атрибутов (например, стоимости маршрута) текущая запись закрывается (`is_current=false`, `valid_to=текущая_дата`), и создается новая версия с обновленными данными (`is_current=true`, `valid_from=текущая_дата`, `valid_to=NULL`). Это позволяет получать данные "на момент времени" и анализировать историю изменений, сохраняя полный аудит всех модификаций в системе.


## Оркестрация с Apache Airflow

В рамках данного проекта такая оркестрация не была реализована, но есть схема, показывающая как это можно было сделать:

```mermaid
graph LR
    Start([Airflow Scheduler<br/>Ежедневно]) --> Task1[Task 1:<br/>Kafka to MinIO<br/>Spark Job]
    Task1 --> Task2[Task 2:<br/>MinIO to DWH<br/>Spark ETL + SCD]
    Task2 --> Task3[Task 3:<br/>DWH to ClickHouse<br/>Spark Aggregation]
    Task3 --> Task4[Task 4:<br/>Data Quality Checks]
    Task4 --> End([Уведомление<br/>Success/Failure])
    
    Task1 -.->|При ошибке| Retry1[Retry 3x]
    Task2 -.->|При ошибке| Retry2[Retry 3x]
    Task3 -.->|При ошибке| Retry3[Retry 3x]
    
    Retry1 -.->|Все попытки failed| Alert[Alert в Slack/Email]
    Retry2 -.->|Все попытки failed| Alert
    Retry3 -.->|Все попытки failed| Alert
```

**Структура:**
- **Task 1**: Чтение из Kafka → запись в MinIO (Parquet)
- **Task 2**: ETL из MinIO → Greenplum (Hubs → Links → Satellites с SCD Type 2)
- **Task 3**: Агрегация из Greenplum → ClickHouse (витрины)
- **Task 4**: Проверка качества данных (row counts, null checks)
