import { useForm } from '@inertiajs/react';
import { useState } from 'react';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from 'recharts';

export default function Index({ tasks, stats }) {
  const [editingId, setEditingId] = useState(null);

  // CREATE TASK FORM
  const {
    data: addData,
    setData: setAddData,
    post,
    reset,
  } = useForm({
    title: '',
    category: 'personal',
  });

  // EDIT TASK FORM
  const [editValues, setEditValues] = useState({});
  
  const chartData = [
    { name: 'Completed', value: stats.completed },
    { name: 'Pending', value: stats.pending },
  ];
  
  const COLORS = ['#22c55e', '#facc15'];
  
  const [filter, setFilter] = useState('all');

  function submit(e) {
    e.preventDefault();

    post('/tasks', {
      onSuccess: () => resetAdd('title'),
    });
  }

  function startEdit(task) {
    setEditingId(task.id);
    setEditValues({ [task.id]: task.title });
  }

  function updateEdit(taskId, value) {
    setEditValues((prev) => ({
      ...prev,
      [taskId]: value,
    }));
  }

  function saveEdit(e, taskId) {
    e.preventDefault();

    put(`/tasks/${taskId}`, {
      data: {
        title: editData.title,
      },
      onSuccess: () => {
        setEditingId(null);
        resetEdit('title');
      },
    });
  }

  function handleKeyDown(e) {
    if (e.key === 'Escape') {
      setEditingId(null);
      resetEdit('title');
    }
  }

  return (
    <div className="min-h-screen bg-gray-100 flex justify-center py-10">
      <div className="w-full max-w-xl bg-white shadow-md rounded-xl p-6">

        <h1 className="text-2xl font-bold mb-6 text-center">
          My Tasks
        </h1>

        {/* STATS */}
        <div className="grid grid-cols-4 gap-3 mb-6">
          <div className="bg-blue-100 p-3 rounded-lg text-center">
            <p className="text-sm text-gray-600">Total</p>
            <p className="text-xl font-bold">{stats.total}</p>
          </div>

          <div className="bg-green-100 p-3 rounded-lg text-center">
            <p className="text-sm text-gray-600">Completed</p>
            <p className="text-xl font-bold">{stats.completed}</p>
          </div>

          <div className="bg-yellow-100 p-3 rounded-lg text-center">
            <p className="text-sm text-gray-600">Pending</p>
            <p className="text-xl font-bold">{stats.pending}</p>
          </div>

          <div className="bg-purple-100 p-3 rounded-lg text-center">
            <p className="text-sm text-gray-600">Progress</p>
            <p className="text-xl font-bold">{stats.completionRate}%</p>
          </div>
        </div>

        {/* PROGRESS BAR */}
        <div className="mb-6">
          <div className="h-3 bg-gray-200 rounded-full">
            <div
              className="h-3 bg-green-500 rounded-full"
              style={{ width: `${stats.completionRate}%` }}
            />
          </div>
        </div>
		
		<div className="mb-8 h-64">
		  <h2 className="text-center font-semibold mb-2">
			Task Breakdown
		  </h2>

		  <ResponsiveContainer width="100%" height="100%">
			<PieChart>
			  <Pie
				data={chartData}
				dataKey="value"
				nameKey="name"
				outerRadius={80}
				label
			  >
				{chartData.map((entry, index) => (
				  <Cell key={index} fill={COLORS[index]} />
				))}
			  </Pie>

			  <Tooltip />
			</PieChart>
		  </ResponsiveContainer>
		</div>

        {/* CREATE TASK */}
        <form onSubmit={submit} className="flex gap-2 mb-6">
          <input
            className="flex-1 border rounded-lg px-3 py-2"
            value={addData.title}
            onChange={(e) => setAddData('title', e.target.value)}
            placeholder="Enter a task..."
          />
		  <select
			className="border rounded-lg px-2"
			value={addData.category}
			onChange={(e) => setAddData('category', e.target.value)}
		  >
			<option value="personal">Personal</option>
			<option value="work">Work</option>
			<option value="school">School</option>
			<option value="side">Side Project</option>
		  </select>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg">
            Add
          </button>
        </form>
		
		<div className="flex gap-2 mb-4 justify-center">

		  <button
			onClick={() => setFilter('all')}
			className={`px-3 py-1 rounded ${
			  filter === 'all' ? 'bg-blue-600 text-white' : 'bg-gray-200'
			}`}
		  >
			All
		  </button>

		  <button
			onClick={() => setFilter('work')}
			className={`px-3 py-1 rounded ${
			  filter === 'work' ? 'bg-blue-600 text-white' : 'bg-gray-200'
			}`}
		  >
			Work
		  </button>

		  <button
			onClick={() => setFilter('personal')}
			className={`px-3 py-1 rounded ${
			  filter === 'personal' ? 'bg-blue-600 text-white' : 'bg-gray-200'
			}`}
		  >
			Personal
		  </button>

		  <button
			onClick={() => setFilter('school')}
			className={`px-3 py-1 rounded ${
			  filter === 'school' ? 'bg-blue-600 text-white' : 'bg-gray-200'
			}`}
		  >
			School
		  </button>
		  
		  <button
		    onClick={() => setFilter('completed')}
		    className={`px-3 py-1 rounded ${
			  filter === 'completed' ? 'bg-green-600 text-white' : 'bg-gray-200'
		    }`}
		  >
		    Completed
		  </button>

		</div>

        {/* TASK LIST */}
        <div className="space-y-3">

          {tasks.length === 0 && (
            <p className="text-gray-500 text-center">
              No tasks yet
            </p>
          )}

          {tasks
		    .filter((task) => {
			  if (filter === 'all') return true;
			  if (filter === 'completed') return task.completed;
			  return task.category === filter;
		    })
		    .map((task) => (
            <div
              key={task.id}
              className="flex justify-between items-center border rounded-lg p-3"
            >

              {/* LEFT SIDE */}
              <div className="flex-1">

                {editingId === task.id ? (
                  <form onSubmit={(e) => saveEdit(e, task.id)} className="flex gap-2 w-full">
				    <input
					  className="w-full border px-2 py-1 rounded"
					  value={editValues[task.id] || ''}
					  onChange={(e) => updateEdit(task.id, e.target.value)}
					  autoFocus
				    />

				    <button className="bg-blue-500 text-white px-2 rounded">
					  Save
				    </button>

				    <button
					  type="button"
					  onClick={() => setEditingId(null)}
					  className="bg-gray-300 px-2 rounded"
				    >
					  Cancel
				    </button>
				  </form>
                ) : (
                  <div className="flex items-center gap-2">
				    <span
					  onClick={() => startEdit(task)}
					  className={
					    task.completed
						  ? 'line-through text-gray-400 cursor-pointer'
						  : 'cursor-pointer'
					  }
				    >
					  {task.title}
				    </span>

				    <span className="text-xs bg-gray-200 px-2 py-1 rounded">
					  {task.category}
				    </span>
				  </div>
                )}

              </div>

              {/* ACTIONS */}
              <div className="flex gap-2">

                <form method="post" action={`/tasks/${task.id}`}>
                  <input type="hidden" name="_method" value="put" />
                  <input type="hidden" name="toggle" value="1" />
                  <button className="text-sm bg-green-500 text-white px-2 py-1 rounded">
                    {task.completed ? 'Undo' : 'Done'}
                  </button>
                </form>

                <form method="post" action={`/tasks/${task.id}`}>
                  <input type="hidden" name="_method" value="delete" />
                  <button className="text-sm bg-red-500 text-white px-2 py-1 rounded">
                    Delete
                  </button>
                </form>

              </div>

            </div>
          ))}

        </div>

      </div>
    </div>
  );
}