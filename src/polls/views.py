from django.http import HttpResponse
from django.shortcuts import render, get_object_or_404
from .models import Poll

def index(request):
    latest_poll_list = Poll.objects.order_by('-pub_date')[:5]
    context = {
        'latest_poll_list': latest_poll_list,
    }

    return render(request, 'polls/index.html', context)


def detail(request, poll_id):
    poll = get_object_or_404(Poll, pk=poll_id)
    return render(request,
        'polls/detail.html',
        {
            'poll': poll,
            'choices': poll.choice_set.all(),
        })


def results(request, poll_id):
    return HttpResponse("You are looking at the results of poll %s." % poll_id)


def vote(request, poll_id):
    return HttpResponse("You are voting on poll %s." % poll_id)
