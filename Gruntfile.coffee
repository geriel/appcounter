module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')

	replacements =
		dev:
			'//VTEX_IO_HOST/VERSION_DIRECTORY': ''
			'VERSION_NUMBER': pkg.version
		dist:
			'VTEX_IO_HOST': 'io.vtex.com.br'
			'VERSION_NUMBER': pkg.version

	# Project configuration.
	grunt.initConfig
		relativePath: ''

		# Tasks
		clean: 
			main: ['build', 'build-raw', 'tmp-deploy']

		copy:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**', '!coffee/**', '!**/*.less']
					dest: 'build-raw/<%= relativePath %>'
				,
					src: ['src/index.html']
					dest: 'build-raw/<%= relativePath %>/index.debug.html'
				]
			build:
				expand: true
				cwd: 'build-raw/'
				src: '**/*.*'
				dest: 'build/'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'build-raw/<%= relativePath %>/js/'
					ext: '.js'
				]

		less:
			main:
				files:
					'build-raw/<%= relativePath %>/style/main.css': 'src/style/main.less'

		useminPrepare:
			html: 'build-raw/<%= relativePath %>/index.html'

		usemin:
			html: 'build-raw/<%= relativePath %>/index.html'
			options: {script: true, css: true, image: false, require: false, datatags: false, background: false, anchors: false, input: false}

		### example - we actually use grunt-usemin to min. check index.html for the build tags
		uglify:
  		options:
  			mangle: false
			dist:
				files:
					'dist/people.min.js': ['dist/people.js']
		###

		karma:
			options:
				configFile: 'karma.conf.coffee'
			unit:
				background: true
			single:
				singleRun: true

		'string-replace':
			dev:
				files:
					'build/<%= relativePath %>/index.html': ['build-raw/<%= relativePath %>/index.html']
					'build/<%= relativePath %>/index.debug.html': ['build-raw/<%= relativePath %>/index.debug.html']
					'build/<%= relativePath %>/js/app.js': ['build-raw/<%= relativePath %>/js/app.js']
					'build/<%= relativePath %>/js/main.js': ['build-raw/<%= relativePath %>/js/main.js']
				options:
					replacements: ({'pattern': new RegExp(key, "g"), 'replacement': value} for key, value of replacements.dev)
			dist:
				files:
					'build/<%= relativePath %>/index.html': ['build-raw/<%= relativePath %>/index.html']
					'build/<%= relativePath %>/index.debug.html': ['build-raw/<%= relativePath %>/index.debug.html']
					'build/<%= relativePath %>/js/app.js': ['build-raw/<%= relativePath %>/js/app.js']
					'build/<%= relativePath %>/js/main.js': ['build-raw/<%= relativePath %>/js/main.js']
				options:
					replacements: ({'pattern': new RegExp(key, "g"), 'replacement': value} for key, value of replacements.dist)

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		remote: main: {}

		watch:
			dev:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.coffee', 'spec/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'src/**/*.css']
				tasks: ['clean', 'concurrent:transform', 'copy:build', 'string-replace:dev', 'karma:unit:run']

		concurrent:
			transform: ['copy:main', 'coffee', 'less']

		vtex_deploy:
			main:
				options:
					buildDirectory: 'build/<%= relativePath %>'
					indexPath: 'build/index.html'
					whoamiPath: 'whoami'
					includeHostname:
						hostname: 'io.vtex.com.br'
						files: ["build/index.html", "build/index.debug.html", "build/js/app.js", "build/js/main.js"]
			walmart:
				options:
					buildDirectory: 'build-raw/<%= relativePath %>'
					indexPath: 'build-raw/index.html'
					indexOnRoot: true
					bucket: 'vtex-io-walmart'
					requireEnvironmentType: 'stable'
					includeHostname:
						hostname: 'VTEX_IO_HOST'
						files: ["build-raw/index.html", "build-raw/index.debug.html", "build-raw/js/app.js", "build-raw/js/main.js"]

	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'concurrent:transform', 'copy:build', 'string-replace:dev', 'server', 'karma:unit', 'watch']
	grunt.registerTask 'min', ['useminPrepare', 'concat', 'uglify', 'cssmin', 'usemin'] # minifies files
	grunt.registerTask 'devmin', ['clean', 'concurrent:transform', 'min', 'copy:build', 'string-replace:dev', 'server', 'watch'] # Dev - minifies files
	grunt.registerTask 'dist', ['clean', 'concurrent:transform', 'min', 'copy:build', 'string-replace:dist'] # Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['connect', 'remote']
