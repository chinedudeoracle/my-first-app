<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    /**
     * Display a listing of the resource.
     */
	public function index()
	{
		$tasks = auth()->user()->tasks()->latest()->get();

		$total = $tasks->count();
		$completed = $tasks->where('completed', true)->count();
		$pending = $tasks->where('completed', false)->count();

		$completionRate = $total > 0
			? round(($completed / $total) * 100)
			: 0;

		return inertia('Tasks/Index', [
			'tasks' => $tasks,
			'stats' => [
				'total' => $total,
				'completed' => $completed,
				'pending' => $pending,
				'completionRate' => $completionRate,
			]
		]);
	}

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
        'title' => 'required|string|max:255',
		]);

		auth()->user()->tasks()->create([
			'title' => $request->title,
			'category' => $request->category ?? 'personal',
		]);

		return redirect()->back();
    }

    /**
     * Display the specified resource.
     */
    public function show(Task $task)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Task $task)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Task $task)
    {
        // ensure user owns task
		abort_unless($task->user_id === auth()->id(), 403);

		$request->validate([
			'title' => 'nullable|string|max:255',
		]);

		$task->update([
			'title' => $request->title ?? $task->title,
			'completed' => $request->has('toggle')
				? !$task->completed
				: $task->completed,
		]);

		return redirect()->back();
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Task $task)
    {
		abort_unless($task->user_id === auth()->id(), 403);

		$task->delete();

		return redirect()->back();
    }
}
