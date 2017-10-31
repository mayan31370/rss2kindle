package org.roag.ds.mongo;

import com.mongodb.WriteResult;
import org.apache.camel.CamelContext;
import org.apache.camel.ProducerTemplate;
import org.roag.ds.OperationResult;
import org.roag.ds.UserRepository;
import org.roag.model.User;
import org.roag.model.UserStatus;
import org.roag.service.SubscriberFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Created by eurohlam on 31/10/2017.
 */
public class MongoUserRepository implements UserRepository
{
    final private Logger logger = LoggerFactory.getLogger(MongoUserRepository.class);

    private CamelContext context;
    private ProducerTemplate producerTemplate;
    private MongoHelper mongoHelper;

    public MongoUserRepository(MongoHelper mongoHelper, CamelContext context)
    {
        this.mongoHelper = mongoHelper;
        assert context != null;
        this.context = context;
        this.producerTemplate = context.createProducerTemplate();
    }

    public CamelContext getCamelContext()
    {
        return context;
    }

    public ProducerTemplate getProducerTemplate()
    {
        return producerTemplate;
    }

    public MongoHelper getMongoHelper()
    {
        return mongoHelper;
    }

    @Override
    public List<User> findAll() throws Exception
    {
        return findAll(Collections.EMPTY_MAP);
    }

    @Override
    public List<User> findAll(Map condition) throws Exception
    {
        logger.debug("Fetch all users from Mongo by condition {}", condition);
        List<User> users = mongoHelper.findAllByCondition(producerTemplate, condition);
        return users;
    }

    @Override
    public User getUser(String username) throws Exception {
        logger.debug("Fetch user {} from Mongo", username);
        User user = mongoHelper.getUser(username, producerTemplate);
        return user;
    }

    @Override
    public OperationResult addUser(User user) throws Exception {
        logger.debug("Add new user {}", user.getUsername());
        WriteResult r = mongoHelper.addUser(user, producerTemplate);
        logger.info("Added user {} with the result {}", user.getUsername(), r.toString().replaceFirst("WriteResult", ""));
        return OperationResult.SUCCESS;
    }

    @Override
    public OperationResult updateUser(User user) throws Exception {
        logger.debug("Update user {}", user.getUsername());
        WriteResult r = mongoHelper.updateUser(user, producerTemplate);
        logger.info("Updated user {} with the result {}", user.getUsername(), r.toString().replaceFirst("WriteResult", ""));
        return r.getN()>0?OperationResult.SUCCESS:OperationResult.NOT_EXIST;
    }

    @Override
    public OperationResult removeUser(String username) throws Exception {
        logger.debug("Remove user {}", username);
        WriteResult r = mongoHelper.removeUser(username, producerTemplate);
        logger.info("Removeed user {} with the result {}", username, r.toString().replaceFirst("WriteResult", ""));
        return r.getN()>0?OperationResult.SUCCESS:OperationResult.NOT_EXIST;
    }

    @Override
    public OperationResult lockUser(String username) throws Exception {
        User user= getUser(username);
        user.setStatus(UserStatus.LOCKED.toString());
        logger.warn("Trying to lock user {}", username);
        return updateUser(user);
    }

    @Override
    public OperationResult unlockUser(String username) throws Exception {
        User user= getUser(username);
        user.setStatus(UserStatus.ACTIVE.toString());
        logger.warn("Trying to activate user {}", username);
        return updateUser(user);
    }

}
