from django.db import models
from django.utils import timezone

class Poll(models.Model):
    question = models.CharField(max_length=200)
    pub_date = models.DateTimeField('date published')

    def was_published_recently(self):
        return self.pub_date >= timezone.now() - timezone.timedelta(days=1)
    was_published_recently.admin_order_field = 'pub_date'
    was_published_recently.boolean = True
    was_published_recently.short_description = 'Published recently?'


    class Meta:
        verbose_name = 'Poll'
        verbose_name_plural = 'Polls'

    def __unicode__(self):
        return self.question


class Choice(models.Model):
    poll = models.ForeignKey(Poll)
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)

    class Meta:
        verbose_name = 'Choice'
        verbose_name_plural = 'Choices'

    def __unicode__(self):
        return self.choice_text
