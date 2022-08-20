import time
from locust import HttpUser, task, between


class WebsiteUser(HttpUser):
    #wait_time = between(1, 5)

    @task
    def slow_page(self):
        self.client.post(url="/api/orders/create",json=
            {
            "name":"sourabh"
            }
            )  
