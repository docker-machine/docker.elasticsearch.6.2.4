# Elasticsearch IK 中文分词

## Step1: 获取当前Elasticsearch索引(数据库)列表数据.

```http request
GET http://localhost:9200/_cat/indices?v
Accept: application/json
```

```json
[
  {
    "health": "green",
    "status": "open",
    "index": "elasticsearch",
    "uuid": "rZbrezYbTXaMouxQ_q1ByQ",
    "pri": "1",
    "rep": "1",
    "docs.count": "0",
    "docs.deleted": "0",
    "store.size": "416b",
    "pri.store.size": "208b"
  },
  {
    "health": "green",
    "status": "open",
    "index": "hello-world",
    "uuid": "SJZsKujNQ3ucgeZPWCHhvg",
    "pri": "1",
    "rep": "1",
    "docs.count": "5",
    "docs.deleted": "0",
    "store.size": "14.9kb",
    "pri.store.size": "7.4kb"
  },
  {
    "health": "green",
    "status": "open",
    "index": "hello",
    "uuid": "wVIJyVCOS_KvNMpycp9jgQ",
    "pri": "1",
    "rep": "1",
    "docs.count": "0",
    "docs.deleted": "0",
    "store.size": "416b",
    "pri.store.size": "208b"
  }
]
```

## Step2: 添加名称为hello-world的索引到Elasticsearch.

```http request
PUT http://localhost:9200/hello-world
Accept: application/json
```

如果不存在 `hello-world` 索引，则创建成功，输出如下所示：

```json
{
  "acknowledged": true,
  "shards_acknowledged": true,
  "index": "hello-world"
}
```

如果存在 `hello-world` 索引，则创建失败，输出如下所示：

```json
{
  "error": {
    "root_cause": [
      {
        "type": "resource_already_exists_exception",
        "reason": "index [hello-world/1Nk1nhCQR4OMmSMRquH_6Q] already exists",
        "index_uuid": "1Nk1nhCQR4OMmSMRquH_6Q",
        "index": "hello-world"
      }
    ],
    "type": "resource_already_exists_exception",
    "reason": "index [hello-world/1Nk1nhCQR4OMmSMRquH_6Q] already exists",
    "index_uuid": "1Nk1nhCQR4OMmSMRquH_6Q",
    "index": "hello-world"
  },
  "status": 400
}
```

## Step3: 查询名称为hello-world的索引结构.

```http request
GET http://localhost:9200/hello-world
Accept: application/json
```

这将会返回 `hello-world` 索引的具体结构信息如下：

```json
{
  "hello-world": {
    "aliases": {},
    "mappings": {},
    "settings": {
      "index": {
        "routing": {
          "allocation": {
            "include": {
              "_tier_preference": "data_content"
            }
          }
        },
        "number_of_shards": "1",
        "provided_name": "hello-world",
        "creation_date": "1615738697591",
        "number_of_replicas": "1",
        "uuid": "1Nk1nhCQR4OMmSMRquH_6Q",
        "version": {
          "created": "7110199"
        }
      }
    }
  }
}
```


## Step4: 创建名称为hello-world索引的mapping(发送POST请求与JSON主体).

```http request
POST http://localhost:9200/hello-world/_mapping
Content-Type: application/json

{
        "properties": {
            "content": {
                "type": "text",
                "analyzer": "ik_max_word",
                "search_analyzer": "ik_smart"
            }
        }
}
```

这将为 `hello-world` 索引添加mapping，响应数据如下：

```json
{
  "acknowledged": true
}
```

## Step5: 向名称为hello-world的索引添加一些文档(Document).

```http request
POST http://localhost:9200/hello-world/_create/1
Content-Type: application/json

{"content":"美国留给伊拉克的是个烂摊子吗"}
```

```http request
POST http://localhost:9200/hello-world/_create/2
Content-Type: application/json

{"content":"公安部：各地校车将享最高路权"}
```

```http request
POST http://localhost:9200/hello-world/_create/3
Content-Type: application/json

{"content":"中韩渔警冲突调查：韩警平均每天扣1艘中国渔船"}
```

```http request
POST http://localhost:9200/hello-world/_create/4
Content-Type: application/json

{"content":"中国驻洛杉矶领事馆遭亚裔男子枪击 嫌犯已自首"}
```

```http request
POST http://localhost:9200/hello-world/_create/5
Content-Type: application/json

{"content":"缅甸中企遭打砸抢烧 中使馆回应"}
```

如果ID不存在，则添加成功，具体响应数据如下：

```json
{
  "_index": "hello-world",
  "_type": "_doc",
  "_id": "1",
  "_version": 1,
  "result": "created",
  "_shards": {
    "total": 2,
    "successful": 2,
    "failed": 0
  },
  "_seq_no": 0,
  "_primary_term": 1
}
```

如果ID存在，则添加失败，具体响应数据如下：

```json
{
  "error": {
    "root_cause": [
      {
        "type": "version_conflict_engine_exception",
        "reason": "[1]: version conflict, document already exists (current version [1])",
        "index_uuid": "1Nk1nhCQR4OMmSMRquH_6Q",
        "shard": "0",
        "index": "hello-world"
      }
    ],
    "type": "version_conflict_engine_exception",
    "reason": "[1]: version conflict, document already exists (current version [1])",
    "index_uuid": "1Nk1nhCQR4OMmSMRquH_6Q",
    "shard": "0",
    "index": "hello-world"
  },
  "status": 409
}
```

## Step6: 带突出显示的查询.

```http request
POST http://localhost:9200/hello-world/_search
Content-Type: application/json

{
  "query" : { "match" : { "content" : "中国" } },
  "highlight" : {
    "pre_tags" : ["<tag1>", "<tag2>"],
    "post_tags" : ["</tag1>", "</tag2>"],
    "fields" : {
      "content" : {}
    }
  }
}
```

具体响应数据如下：

```json
{
  "took": 22,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 2,
      "relation": "eq"
    },
    "max_score": 0.8071519,
    "hits": [
      {
        "_index": "hello-world",
        "_type": "_doc",
        "_id": "3",
        "_score": 0.8071519,
        "_source": {
          "content": "中韩渔警冲突调查：韩警平均每天扣1艘中国渔船"
        },
        "highlight": {
          "content": [
            "中韩渔警冲突调查：韩警平均每天扣1艘<tag1>中国</tag1>渔船"
          ]
        }
      },
      {
        "_index": "hello-world",
        "_type": "_doc",
        "_id": "4",
        "_score": 0.8071519,
        "_source": {
          "content": "中国驻洛杉矶领事馆遭亚裔男子枪击 嫌犯已自首"
        },
        "highlight": {
          "content": [
            "<tag1>中国</tag1>驻洛杉矶领事馆遭亚裔男子枪击 嫌犯已自首"
          ]
        }
      }
    ]
  }
}
```