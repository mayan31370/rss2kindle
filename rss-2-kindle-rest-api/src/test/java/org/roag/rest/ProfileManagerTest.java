package org.roag.rest;

import org.glassfish.jersey.server.ResourceConfig;
import org.glassfish.jersey.test.JerseyTestNg;
import org.roag.ds.SubscriberRepository;
import org.roag.model.Subscriber;
import org.roag.service.SubscriberFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import javax.ws.rs.core.Application;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import static org.junit.Assert.*;

/**
 * Created by eurohlam on 30.08.17.
 */
public class ProfileManagerTest extends JerseyTestNg.ContainerPerClassTest
{

    @Override
    protected Application configure()
    {
        return new ResourceConfig(ProfileManager.class);
    }

    @Test(groups = {"profile"})
    public void getAllSubscriptionsTest()
    {
        final Response response = target("profile/test@mail.com/subscriptions").request().accept(MediaType.APPLICATION_JSON_TYPE).get();

        assertEquals(200, response.getStatus());
    }
}
