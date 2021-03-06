package org.roag.ds.mongo;

import com.mongodb.*;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.component.mongodb.MongoDbOperation;
import org.roag.ds.OperationResult;
import org.roag.service.ModelFactory;
import org.roag.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.*;

/**
 * Created by eurohlam on 05.10.16.
 */
public class MongoHelper {

    private final Logger logger = LoggerFactory.getLogger(MongoHelper.class);

    private static final String MONGO_FIELD_USERNAME = "username";
    private static final String MONGO_FIELD_ID = "_id";

    private String mongoSpringBean;

    private String defaultMongoDatabase;

    private String defaulMongoCollection;

    private ModelFactory modelFactory;

    private MongoHelper() {
    }

    public MongoHelper(String mongoBean) {
        this(mongoBean, null, null);
    }

    public MongoHelper(String mongoBean, String mongoDatabase, String mongoCollection) {
        this.mongoSpringBean = mongoBean;
        this.defaultMongoDatabase = mongoDatabase;
        this.defaulMongoCollection = mongoCollection;
        this.modelFactory = new ModelFactory();
    }

    public String getDefaultMongoDatabase() {
        return defaultMongoDatabase;
    }

    public String getDefaulMongoCollection() {
        return defaulMongoCollection;
    }

    DBObject findOneByCondition(ProducerTemplate producerTemplate, Map<String, String> conditions) throws Exception {
        return findOneByCondition(defaultMongoDatabase, defaulMongoCollection, producerTemplate, conditions);
    }

    DBObject findOneByCondition(String database, String collection, ProducerTemplate producerTemplate,
                                Map<String, String> conditions) throws Exception {
        List<DBObject> r = findByCondition(database, collection, MongoDbOperation.findOneByQuery, producerTemplate, conditions);
        return r == null || r.isEmpty() ? null : r.get(0);
    }


    List<DBObject> findAllByCondition(ProducerTemplate producerTemplate, Map<String, String> conditions) throws Exception {
        return findAllByCondition(defaultMongoDatabase, defaulMongoCollection, producerTemplate, conditions);
    }

    List<DBObject> findAllByCondition(String database, String collection, ProducerTemplate producerTemplate,
                                      Map<String, String> conditions) throws Exception {
        return findByCondition(database, collection, MongoDbOperation.findAll, producerTemplate, conditions);
    }

    private List<DBObject> findByCondition(String mongoDatabase, String collection, MongoDbOperation operation,
                                           ProducerTemplate producerTemplate, Map<String, String> conditions)
            throws Exception {
        List<DBObject> list = null;
        DBObject query = BasicDBObjectBuilder.start(conditions).get();
        Object result = producerTemplate.requestBody(getQuery(mongoDatabase, collection, operation), query);
        if (result == null) {
            logger.warn("Nothing found in Mongo for {}", conditions);
            return Collections.emptyList();
        }

        if (result instanceof DBObject) {
            list = new ArrayList<>(1);
            list.add((DBObject) result);
        } else {
            list = (List) result;
        }

        if (logger.isDebugEnabled()) {
            logger.debug("findByCondition {} returned the following results:", operation);
            list.forEach(
                    obj -> obj.keySet().forEach(
                            key -> logger.debug("key = {}  value = {}", key, obj.get(key))
                    )
            );
        }
        return list;
    }

    String getQuery(String mongoDatabase, String collection, MongoDbOperation operation) {
        return "mongodb:" + mongoSpringBean + "?database=" + mongoDatabase
                + "&collection=" + collection + "&operation=" + operation.toString();
    }

    public List<User> getAllUsers(ProducerTemplate producerTemplate) throws Exception {
        return getUsers(producerTemplate, Collections.emptyMap());
    }

    public List<User> getUsers(ProducerTemplate producerTemplate, Map<String, String> condition) throws Exception {
        List<DBObject> result = findAllByCondition(producerTemplate, condition);
        List<User> users = new ArrayList<>(result.size());
        for (DBObject object : result) {
            object.removeField(MONGO_FIELD_ID);
            User user = modelFactory.json2Pojo(User.class, modelFactory.pojo2Json(object));
            users.add(user);
        }
        return users;
    }

    public User getUser(String username, ProducerTemplate producerTemplate) throws Exception {
        Map<String, String> cond = new HashMap<>(2);
        cond.put(MONGO_FIELD_USERNAME, username);
        DBObject result = findOneByCondition(producerTemplate, cond);
        if (result == null) {
            throw new IllegalArgumentException("User " + username + " has not been found");
        }

        result.removeField(MONGO_FIELD_ID);
        User user = modelFactory.json2Pojo(User.class, modelFactory.pojo2Json(result));
        BasicDBList subscribers = (BasicDBList) result.get("subscribers");
        logger.info("GET: User: {} with status {} \n {} {}", user.getUsername(), user.getStatus(), subscribers.getClass(), subscribers);
        return user;

    }

    public OperationResult addUser(User user, ProducerTemplate producerTemplate) throws Exception {
        user.setDateCreated(LocalDateTime.now().toString());
        Map<String, String> cond = new HashMap<>(1);
        cond.put(MONGO_FIELD_USERNAME, user.getUsername());
        DBObject r = findOneByCondition(producerTemplate, cond);
        if (r != null) {
            throw new IllegalArgumentException("Creation is impossible. User " + user.getUsername() + " already exists");
        }

        Object result = producerTemplate.requestBody(
                getQuery(getDefaultMongoDatabase(), getDefaulMongoCollection(), MongoDbOperation.insert),
                modelFactory.pojo2Json(user));

        logger.info("INSERT: New user: {} has been inserted into Mongo with the result: {}", user.getUsername(), result);
        logger.debug("INSERT: result: {}", result);
        return OperationResult.SUCCESS;
    }

    public OperationResult updateUser(User user, ProducerTemplate producerTemplate) throws Exception {
        user.setDateModified(LocalDateTime.now().toString());
        Map<String, String> cond = new HashMap<>(1);
        cond.put(MONGO_FIELD_USERNAME, user.getUsername());
        DBObject r = findOneByCondition(producerTemplate, cond);
        if (r == null) {
            throw new IllegalArgumentException("Update is impossible. User " + user.getUsername() + " does not exist");
        }

        DBObject filterField = new BasicDBObject(MONGO_FIELD_USERNAME, user.getUsername());
        DBObject obj = new BasicDBObject("$set",
                BasicDBObjectBuilder.start(modelFactory.json2Pojo(Map.class, modelFactory.pojo2Json(user))).get());
        Object result = producerTemplate.requestBody(
                getQuery(getDefaultMongoDatabase(), getDefaulMongoCollection(), MongoDbOperation.update),
                new Object[]{filterField, obj});//TODO: process UpdateResult

        logger.info("UPDATE: User: {} has been updated into Mongo with the result: {}", user.getUsername(), result);
        logger.debug("UPDATE: result: {}", result);
        return OperationResult.SUCCESS;
    }

    public OperationResult removeUser(String username, ProducerTemplate producerTemplate) throws Exception {
        DBObject query = new BasicDBObject(MONGO_FIELD_USERNAME, username);
        Object result = producerTemplate.requestBody(
                getQuery(getDefaultMongoDatabase(), getDefaulMongoCollection(), MongoDbOperation.remove),
                query); //TODO: process DeleteResult

        logger.warn("DELETE: User: {} has been removed from Mongo with the result: {}", username, result);
        logger.debug("DELETE: result: {}", result);
        return OperationResult.SUCCESS;
    }
}
