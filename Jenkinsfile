pipeline {
  options { timestamps() }
  agent any
  environment {
    PROJECT = "GlitchInTheSystem"
    EXPORT = "export"
    BUCKET_NAME = "sumu-games-pkg-us-east-1"
    ITCH_ADDRESS = "joebmanley/glitchinthesystem"
  }
  stages {
    stage('Test')
    {
        when
        {
            expression
            {
                fileExists 'Scripts/testing.gd'
            }
        }
        steps{
            sh("godot -s Scripts/testing.gd")
        }
    }
    stage('Build') {
      steps {
          script
          {
              sh("mkdir Builds")
              if(env.BRANCH_NAME != "develop")
              {
                  env.EXPORT = "export_debug"
              }
            sh("""
            mkdir Builds/Linux
            mkdir Builds/Linux/${PROJECT}
            godot --${export} Linux/X11 Builds/Linux/${PROJECT}/${PROJECT}
            """)
            sh("""
            mkdir Builds/Windows
            mkdir Builds/Windows/${PROJECT}
            godot --${export} "Windows Desktop" Builds/Windows/${PROJECT}/${PROJECT}.exe
            """)
            sh("""
            mkdir Builds/Mac
            mkdir Builds/Mac/${PROJECT}
            godot --${export} "Mac OSX" Builds/Mac/${PROJECT}/${PROJECT}
            """)
            sh("""
            mkdir Builds/html5
            mkdir Builds/html5/${PROJECT}
            godot --${export} "HTML5" Builds/html5/index.html
            """)
          }
      }
    }
    stage('Package Artifacts')
    {
        steps
        {
            dir ("Builds/Linux/") {
                sh("zip ../${PROJECT}-linux.zip ${PROJECT} -r")
            }
            dir ("Builds/Windows/") {
                sh("zip ../${PROJECT}-windows.zip ${PROJECT} -r")
            }
            dir ("Builds/Mac/") {
                sh("zip ../${PROJECT}-mac.zip ${PROJECT} -r")
            }
            dir ("Builds/html5/") {
                sh("zip ../${PROJECT}-html5.zip * -r")
            }
        }
    }
    stage('Ship to S3')
    {
      steps {
          sh("aws s3 cp Builds/${PROJECT}-linux.zip s3://${BUCKET_NAME}/${PROJECT}/${env.BRANCH_NAME}/${PROJECT}-linux.zip")
          sh("aws s3 cp Builds/${PROJECT}-windows.zip s3://${BUCKET_NAME}/${PROJECT}/${env.BRANCH_NAME}/${PROJECT}-windows.zip")
          sh("aws s3 cp Builds/${PROJECT}-mac.zip s3://${BUCKET_NAME}/${PROJECT}/${env.BRANCH_NAME}/${PROJECT}-mac.zip")
          sh("aws s3 cp Builds/${PROJECT}-html5.zip s3://${BUCKET_NAME}/${PROJECT}/${env.BRANCH_NAME}/${PROJECT}-html5.zip")
      }
    }
    stage('Ship to Itch.io')
    {
     when {
          expression {
              env.BRANCH_NAME == 'develop'
          }
      }
      steps {
          sh("butler push Builds/${PROJECT}-linux.zip ${ITCH_ADDRESS}:linux --userversion ${env.BRANCH_NAME}")
          sh("butler push Builds/${PROJECT}-windows.zip ${ITCH_ADDRESS}:windows --userversion ${env.BRANCH_NAME}")
          sh("butler push Builds/${PROJECT}-mac.zip ${ITCH_ADDRESS}:osx --userversion ${env.BRANCH_NAME}")
          sh("butler push Builds/${PROJECT}-html5.zip ${ITCH_ADDRESS}:html5 --userversion ${env.BRANCH_NAME}")
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}